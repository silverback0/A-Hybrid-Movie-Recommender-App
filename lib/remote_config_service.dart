import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {

  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  Future<void> initialize() async {

    try {

      await Firebase.initializeApp();

      final settings =
          RemoteConfigSettings(
        fetchTimeout:
            const Duration(seconds: 10),

        minimumFetchInterval:
            const Duration(minutes: 1),
      );

      await _remoteConfig
          .setConfigSettings(settings);

      await _remoteConfig
          .setDefaults({

        'api_base_url':
            'http://10.0.2.2:8000'

      });

      await _remoteConfig
          .fetchAndActivate();

    } catch (e) {

      print(
        'Remote config error: $e'
      );
    }
  }

  String get apiBaseUrl {

    return _remoteConfig.getString(
      'api_base_url'
    );
  }
}