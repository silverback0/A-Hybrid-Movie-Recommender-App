import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_movie_recommender_app/userprofile.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final UserProfileService _userProfileService;

  AuthenticationService(this._firebaseAuth, this._userProfileService);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the newly created user's UID
      final uid = userCredential.user?.uid;

      if (uid != null) {
        // Update the user's display name
        await userCredential.user?.updateDisplayName(name);

        // Create a UserProfile instance
        final newUserProfile = UserProfile(uid: uid, name: name, email: email);

        // Add the user profile to Firestore
        await _userProfileService.addUserProfile(newUserProfile);
        // Fetch the user profile to print its data
        final userProfile = await _userProfileService
            .getUserProfile(_firebaseAuth.currentUser!.uid);
        print('Fetched UserProfile: $userProfile');

        return null; // Successful sign-up
      } else {
        return "An error occurred while signing up"; // Handle error
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Handle error
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
