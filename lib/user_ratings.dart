import 'package:cloud_firestore/cloud_firestore.dart';

class UserRating {
  final String mediaId;
  final double rating;

  UserRating(this.mediaId, this.rating);
}

class UserRatingsService {
  final CollectionReference _userRatingsCollection =
      FirebaseFirestore.instance.collection('userRatings');

  Future<void> addUserRating(String mediaId, double rating) async {
    await _userRatingsCollection.add({
      'mediaId': mediaId,
      'rating': rating,
    });
  }

  Future<List<UserRating>> getUserRatings() async {
    final querySnapshot = await _userRatingsCollection.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null &&
          data.containsKey('mediaId') &&
          data.containsKey('rating')) {
        final mediaId = data['mediaId'] as String;
        final rating = data['rating'] as double;
        return UserRating(mediaId, rating);
      } else {
        throw Exception("Invalid data format in Firestore document");
      }
    }).toList();
  }

  Future<List<UserRating>> fetchUserRatings() async {
    try {
      List<UserRating> userRatings = await getUserRatings();
      return userRatings;
    } catch (e) {
      print("Error fetching user ratings: $e");
      return [];
    }
  }
}
