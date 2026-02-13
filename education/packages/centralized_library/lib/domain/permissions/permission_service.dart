// lib/core/permissions/permission_service.dart

import 'app_permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final AppPermissionHandler _permissionHandler = AppPermissionHandler();

  /// Check if all required permissions are granted
  Future<bool> arePermissionsGrantedAsync() async {
    return await _permissionHandler.isStoragePermissionGrantedAsync();
  }

  /// Request all required permissions
  Future<bool> requestAllPermissionsAsync() async {
    return await _permissionHandler.requestStoragePermissionAsync();
  }
}