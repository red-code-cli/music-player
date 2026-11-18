import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  /// Check whether user has granted necessary audio & storage permissions
  static Future<bool> hasPermissions() async {
    final audioStatus = await Permission.audio.status;
    final storageStatus = await Permission.storage.status;

    return audioStatus.isGranted || storageStatus.isGranted;
  }

  /// Request permissions dynamically depending on Android version
  static Future<bool> requestPermissions() async {
    // Request notification permission for playback notification (Android 13+)
    await Permission.notification.request();

    // Android 13+ audio permission
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) {
      return true;
    }

    // Fallback for Android 12 and below
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }
}
