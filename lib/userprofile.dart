import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;

  UserProfile({required this.uid, required this.name, required this.email});

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('Data from Firestore: $data');
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'email': email};
  }
}

class UserProfileService {
  final CollectionReference _userProfilesCollection =
      FirebaseFirestore.instance.collection('userProfiles');

  Future<void> addUserProfile(UserProfile userProfile) async {
    await _userProfilesCollection
        .doc(userProfile.uid)
        .set(userProfile.toFirestore());
  }

  Future<UserProfile> getUserProfile(String uid) async {
    final docSnapshot = await _userProfilesCollection.doc(uid).get();
    if (docSnapshot.exists) {
      return UserProfile.fromFirestore(docSnapshot);
    } else {
      throw Exception("User profile not found");
    }
  }

  Future<void> updateUserProfile(String uid, UserProfile userProfile) async {
    await _userProfilesCollection.doc(uid).set(userProfile.toFirestore());
  }
}
