// lib/core/permissions/permission_handler.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  static final AppPermissionHandler _instance = AppPermissionHandler._internal();
  factory AppPermissionHandler() => _instance;
  AppPermissionHandler._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Request storage permissions for caching only
  Future<bool> requestStoragePermissionAsync() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      // Android 13+ doesn't need permission for app-specific storage (cache)
      // Android 12 and below needs WRITE_EXTERNAL_STORAGE for cache
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ - No permission needed for cache directory
        return true;
      } else {
        // Android 12 and below - Request storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need permission for cache directory
      return true;
    }

    return true;
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGrantedAsync() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ - No permission needed for cache
        return true;
      } else {
        // Android 12 and below
        final status = await Permission.storage.status;
        return status.isGranted;
      }
    }

    // iOS doesn't need permission for cache
    return true;
  }

  /// Open app settings if permission is permanently denied
  Future<void> openAppSettingsAsync() async {
    await openAppSettings();
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDeniedAsync() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        return false; // No permission needed on Android 13+
      }

      final status = await Permission.storage.status;
      return status.isPermanentlyDenied;
    }

    return false;
  }
}