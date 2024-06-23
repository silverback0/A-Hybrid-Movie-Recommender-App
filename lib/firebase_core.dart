import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class FirebaseInitializer {
  static Future<FirebaseApp> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    return Firebase.app();
  }
}
