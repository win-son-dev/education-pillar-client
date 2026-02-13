import 'dart:io';
import 'package:centralized_library/centralized_library.dart';
import 'package:flutter/material.dart';

/// Manager class for downloading assets from Firebase Storage to local storage
class FirebaseAssetDownloadManager {
  static final FirebaseAssetDownloadManager _instance =
  FirebaseAssetDownloadManager._internal();

  factory FirebaseAssetDownloadManager() => _instance;

  FirebaseAssetDownloadManager._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Download a file from Firebase Storage to local storage
  ///
  /// [firebasePath] - Path in Firebase Storage (e.g., 'images/photo.jpg')
  /// [localFileName] - Optional custom local file name (defaults to Firebase file name)
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  ///
  /// Returns the local file path where the asset was saved
  Future<String> downloadAsset({
    required String firebasePath,
    String? localFileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Get local directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = localFileName ?? firebasePath.split('/').last;
      final String localPath = '${appDir.path}/$fileName';
      final File localFile = File(localPath);

      // Check if file already exists
      if (await localFile.exists()) {
        debugPrint('File already exists at: $localPath');
        return localPath;
      }

      // Create directory if it doesn't exist
      await localFile.parent.create(recursive: true);

      // Get reference to Firebase file
      final Reference ref = _storage.ref(firebasePath);

      // Download with progress tracking
      final DownloadTask task = ref.writeToFile(localFile);

      // Listen to progress
      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress =
            snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        debugPrint('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for download to complete
      await task;

      debugPrint('Download complete: $localPath');
      return localPath;
    } catch (e) {
      debugPrint('Error downloading asset: $e');
      rethrow;
    }
  }

  /// Download multiple assets in parallel
  ///
  /// Returns a map of firebase paths to local file paths
  Future<Map<String, String>> downloadMultipleAssets({
    required List<String> firebasePaths,
    Function(String path, double progress)? onProgress,
  }) async {
    final Map<String, String> results = {};

    await Future.wait(
      firebasePaths.map((path) async {
        try {
          final localPath = await downloadAsset(
            firebasePath: path,
            onProgress: (progress) => onProgress?.call(path, progress),
          );
          results[path] = localPath;
        } catch (e) {
          debugPrint('Failed to download $path: $e');
        }
      }),
    );

    return results;
  }

  /// Check if asset exists locally
  Future<bool> assetExistsLocally(String localFileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDir.path}/$localFileName');
    return file.exists();
  }

  /// Delete local asset
  Future<void> deleteLocalAsset(String localFileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDir.path}/$localFileName');

    if (await file.exists()) {
      await file.delete();
      debugPrint('Deleted local file: $localFileName');
    }
  }

  /// Get local file path
  Future<String> getLocalPath(String localFileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$localFileName';
  }
}

// ============================================
// MAIN.DART - CHECK & DOWNLOAD ASSETS BEFORE APP STARTS
// ============================================


/// Screen that checks and downloads assets before showing main app
class AssetCheckScreen extends StatefulWidget {
  const AssetCheckScreen({super.key});

  @override
  _AssetCheckScreenState createState() => _AssetCheckScreenState();
}

class _AssetCheckScreenState extends State<AssetCheckScreen> {
  final manager = FirebaseAssetDownloadManager();

  double overallProgress = 0.0;
  String currentFile = '';
  bool isChecking = true;
  bool hasError = false;
  String errorMessage = '';

  // List all assets that need to be downloaded
  final List<String> requiredAssets = [
    'assets/shopping_cart.json',
  ];

  @override
  void initState() {
    super.initState();
    checkAndDownloadAssets();
  }

  Future<void> checkAndDownloadAssets() async {
    try {
      setState(() {
        isChecking = true;
        hasError = false;
      });

      // Check which assets are missing
      List<String> assetsToDownload = [];

      for (String assetPath in requiredAssets) {
        final fileName = assetPath.split('/').last;
        final exists = await manager.assetExistsLocally(fileName);

        if (!exists) {
          assetsToDownload.add(assetPath);
        }
      }

      setState(() => isChecking = false);

      // If all assets exist, go to main app
      if (assetsToDownload.isEmpty) {
        context.go(AppRouteConstants.charity);
        return;
      }

      // Download missing assets
      int completed = 0;
      final total = assetsToDownload.length;

      for (String assetPath in assetsToDownload) {
        setState(() {
          currentFile = assetPath.split('/').last;
        });

        await manager.downloadAsset(
          firebasePath: assetPath,
          onProgress: (progress) {
            setState(() {
              overallProgress = (completed + progress) / total;
            });
          },
        );

        completed++;
        setState(() {
          overallProgress = completed / total;
        });
      }

      // All downloads complete, navigate to main app
      await Future.delayed(Duration(milliseconds: 500));
      context.go(AppRouteConstants.charity);

    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Title
              Icon(
                Icons.cloud_download,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 32),

              // Status Text
              if (isChecking)
                Text(
                  'Checking assets...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                )
              else if (hasError)
                Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Download Failed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                )
              else
                Text(
                  'Downloading assets...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),

              SizedBox(height: 24),

              // Progress Bar
              if (!isChecking && !hasError) ...[
                SizedBox(
                  width: 250,
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '${(overallProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentFile,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // Retry Button (if error)
              if (hasError) ...[
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: checkAndDownloadAssets,
                  child: Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
