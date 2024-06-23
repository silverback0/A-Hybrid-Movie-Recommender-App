import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      // Set custom RemoteConfigSettings
      final remoteConfigSettings = RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10), // Adjust as needed
        minimumFetchInterval:
            const Duration(minutes: 1), // Adjust to your desired interval
      );
      await _remoteConfig.setConfigSettings(remoteConfigSettings);

      await _remoteConfig.setDefaults(<String, dynamic>{
        'flask_ip_address': '',
      });

      await _remoteConfig.fetchAndActivate();
      // Force fetch and activate again
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  String get flaskIpAddress {
    return _remoteConfig.getString('flask_ip_address');
  }
}
