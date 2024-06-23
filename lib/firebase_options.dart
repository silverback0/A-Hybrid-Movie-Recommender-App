import 'package:firebase_core/firebase_core.dart';

// The following values are specific to your project.
const String apiKey = 'AIzaSyBGJnxhEnWqg88fTJ8xzE_5Xo7zvsH7y-Y';
const String authDomain = 'movie-recommender-app-912d2.firebaseapp.com';
const String projectId = 'movie-recommender-app-912d2';
const String storageBucket = 'movie-recommender-app-912d2.appspot.com';
const String messagingSenderId =
    '1:885324992533:android:be988bb11ced03fd6e7e1c';
// Create a FirebaseOptions object.
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: apiKey,
  authDomain: authDomain,
  projectId: projectId,
  storageBucket: storageBucket,
  messagingSenderId: messagingSenderId,
  appId: '',
);
