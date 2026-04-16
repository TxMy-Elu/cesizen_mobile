import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static Uri get baseUri {
    const overrideUrl = String.fromEnvironment('CESIZEN_API_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return Uri.parse(overrideUrl);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse('http://10.0.2.2:8080');
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return Uri.parse('http://localhost:8080');
      case TargetPlatform.fuchsia:
        return Uri.parse('http://localhost:8080');
    }
  }
}