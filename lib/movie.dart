class Media {
  final int id;
  final String title;
  final String overview;
  final String posterUrl;
  final String posterPath;
  final String backdropUrl;
  double rating;
  double userRating;
  String description;
  DateTime releaseDate;
  double voteAverage;
  bool watched;
  List<String> cast;
  List<String> characters;
  List<int> genreIds;
  List<String> genreNames;
  List<Media> similarMedia;

  Media({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.posterPath,
    required this.backdropUrl,
    required this.rating,
    required this.userRating,
    required this.releaseDate,
    required this.voteAverage,
    this.watched = false,
    this.description = '',
    this.cast = const [],
    this.characters = const [],
    this.genreIds = const [],
    this.genreNames = const [],
    this.similarMedia = const [],
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    final genreIds = (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [];

    // Parse the release date using a try-catch block to handle invalid date formats
    DateTime releaseDate;
    try {
      releaseDate = DateTime.parse(json['release_date'] as String? ?? '');
    } catch (e) {
      // Handle the case when the date format is invalid
      releaseDate = DateTime
          .now(); // Provide a default value or handle the error as per your requirement
    }

    return Media(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterUrl:
          'https://image.tmdb.org/t/p/w500${json['poster_path'] as String? ?? ''}',
      backdropUrl:
          'https://image.tmdb.org/t/p/w500${json['backdrop_path'] as String? ?? ''}',
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path'] ?? ''}',
      rating: (json['vote_average'] as num).toDouble(),
      userRating: 0.0, // Replace this with the user's rating if available
      genreIds: genreIds,
      releaseDate: releaseDate,
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterUrl': posterUrl,
      'posterPath': posterPath,
      'backdropUrl': backdropUrl,
      'rating': rating,
      'userRating': userRating,
      'releaseDate': releaseDate.toIso8601String(),
      'voteAverage': voteAverage,
      'watched': watched,
      'description': description,
      'cast': cast,
      'characters': characters,
      'genreIds': genreIds,
      'genreNames': genreNames,
      'similarMedia': similarMedia.map((media) => media.toJson()).toList(),
    };
  }
}
