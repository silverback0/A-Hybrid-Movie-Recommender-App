import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<FirebaseApp> initialize() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static initializeApp() {}
}
