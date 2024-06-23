import 'package:flutter/material.dart';
import 'package:my_movie_recommender_app/movie.dart';
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'dart:convert'; // Import the movie model if needed

class MovieGenres extends StatefulWidget {
  final String apiKey;
  final int selectedGenreId;
  final String genreName;

  const MovieGenres({
    Key? key,
    required this.apiKey,
    required this.selectedGenreId,
    required this.genreName,
  }) : super(key: key);

  @override
  _MovieGenresState createState() => _MovieGenresState();
}

class _MovieGenresState extends State<MovieGenres> {
  List<Media> _genreMedia = [];

  @override
  void initState() {
    super.initState();
    // Fetch genre media when the widget is initialized
    print('Selected Genre ID: ${widget.selectedGenreId}');
    _fetchGenreMedia();
  }

  List<String> fetchGenreNames(List<int> genreIds) {
    final genres = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Science Fiction',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western'
    };

    return genreIds.map((id) => genres[id] ?? '').toList();
  }

  Future<void> _fetchGenreMedia() async {
    try {
      final url =
          'https://api.themoviedb.org/3/discover/movie?api_key=c9c9330b67b52b7f6820d62d28187fb1&with_genres=${widget.selectedGenreId}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        final genreMedia = results.map((mediaData) {
          final media = Media.fromJson(mediaData);
          media.genreNames = fetchGenreNames(media.genreIds);
          return media;
        }).toList();

        // Update the state with genre media
        setState(() {
          _genreMedia = genreMedia;
        });

        // Print the API response for debugging
        print('API Response: $data');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      print('Error during API request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies by Genre: ${widget.genreName}'),
      ),
      body: ListView.builder(
        itemCount: _genreMedia.length,
        itemBuilder: (context, index) {
          final movie = _genreMedia[index];
          return ListTile(
            leading: Image.network(
              'https://image.tmdb.org/t/p/w92${movie.posterPath}',
            ),
            title: Text(movie.title),
            subtitle: Text(
              'Released: ${movie.releaseDate.year}\nRating: ${movie.voteAverage}',
            ),
            // Add any other information or functionality you want to show for each movie
            onTap: () {
              // Add any navigation logic here when the user taps on a movie
            },
          );
        },
      ),
    );
  }
}
