import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override at build/run time:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000`
  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;

    if (kIsWeb) return 'http://localhost:3000';

    // Android emulator host loopback
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    // iOS simulator uses host network; localhost works there.
    // On a physical device, use --dart-define with your machine IP.
    return 'http://localhost:3000';
  }
}
