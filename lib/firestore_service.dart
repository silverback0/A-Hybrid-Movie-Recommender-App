import 'package:cloud_firestore/cloud_firestore.dart';

import 'movie.dart';

class FirestoreService {
  static final instance = FirestoreService();
  final CollectionReference<Map<String, dynamic>> _mediaCollectionRef =
      FirebaseFirestore.instance.collection('media');

  Future<void> saveMedia(Media media) async {
    try {
      final mediaData = media.toJson();
      await _mediaCollectionRef.doc(media.id.toString()).set(mediaData);
    } catch (e) {
      // Handle error
      print('Error saving media: $e');
    }
  }

  Future<Map<String, dynamic>?> getMedia(int id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _mediaCollectionRef.doc(id.toString()).get();
      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      // Handle error
      print('Error retrieving media: $e');
      return null;
    }
  }

  Future<List<Media>> getAllMedia() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _mediaCollectionRef.get();
      return querySnapshot.docs
          .map((doc) => Media.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Handle error
      print('Error retrieving media: $e');
      return [];
    }
  }

  Stream<List<Media>> streamAllMedia() {
    try {
      return _mediaCollectionRef.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Media.fromJson(doc.data())).toList());
    } catch (e) {
      // Handle error
      print('Error streaming media: $e');
      return Stream.value([]);
    }
  }

  Future<List<Media>> fetchUserRatings(int userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _mediaCollectionRef.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs
          .map((doc) => Media.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Handle error
      print('Error retrieving user ratings: $e');
      return [];
    }
  }

  Future<void> saveRecommendation(Media recommendation) async {
    try {
      final recommendationData = recommendation.toJson();
      await _mediaCollectionRef
          .doc(recommendation.id.toString())
          .set(recommendationData);
    } catch (e) {
      // Handle error
      print('Error saving recommendation: $e');
    }
  }
}
