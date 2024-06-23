import 'dart:async';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import '../fetchRecommendMovies.dart'; // Make sure the correct import path is used
import '../movie.dart';
import 'home_page.dart';

class RecommendedMoviesScreen extends StatefulWidget {
  final List<Media> watchlist;

  const RecommendedMoviesScreen({Key? key, required this.watchlist})
      : super(key: key);

  @override
  _RecommendedMoviesScreenState createState() =>
      _RecommendedMoviesScreenState();
}

class _RecommendedMoviesScreenState extends State<RecommendedMoviesScreen> {
  String? _selectedMovie;
  Future<List<dynamic>>? _recommendedMoviesFuture;

  void _onSearch(String movieTitle) {
    // When the user selects a movie from the search, update the state
    setState(() {
      _selectedMovie = movieTitle;
    });

    // Now, you can make the API call to fetch recommendations based on the selected movie
    _loadRecommendedMovies(movieTitle);
  }

  void _loadRecommendedMovies(String movieTitle) async {
    // Use try-catch block to handle any errors while fetching data
    try {
      List<dynamic> recommendedMovies = await fetchRecommendedMovies(
        movieTitle,
      );

      setState(() {
        _recommendedMoviesFuture = Future.value(recommendedMovies);
      });
    } catch (e) {
      setState(() {
        _recommendedMoviesFuture =
            Future.error('Error fetching recommended movies: $e');
      });
    }
  }

  void _navigateToHomePage(BuildContext context, dynamic media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          media: media,
        ), // Pass the appropriate data to the HomePage if needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedMovie == null
            ? const Text('Recommended Movies')
            : Text('Recommended Movies for $_selectedMovie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MovieSearchDelegate(
                  onSearch: _onSearch,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _selectedMovie == null
            ? const Center(
                child: Text('Please search a movie to get recommendations.'),
              )
            : _recommendedMoviesFuture == null
                ? const CircularProgressIndicator()
                : FutureBuilder<List<dynamic>>(
                    future: _recommendedMoviesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text(
                            'Error loading recommended movies: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No recommended movies found.Please use the search in Homepage');
                      }

                      final recommendedMovies = snapshot.data!;

                      return ListView.builder(
                        itemCount: recommendedMovies.length,
                        itemBuilder: (context, index) {
                          final media = recommendedMovies[index];
                          final title = media['title'];
                          final posterPath = media['poster_path'];
                          double rating = media['rating'] ?? 0.0;
                          bool isAddedToWatchlist =
                              media['isAddedToWatchlist'] ?? false;

                          return ListTile(
                            title: Text(title),
                            leading: posterPath != null
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w92$posterPath')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RatingBar.builder(
                                  initialRating: rating,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (newRating) {
                                    setState(() {
                                      media['rating'] = newRating;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isAddedToWatchlist
                                        ? Icons.check_box
                                        : Icons.add_box,
                                    color: isAddedToWatchlist
                                        ? Colors.green
                                        : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      media['isAddedToWatchlist'] =
                                          !isAddedToWatchlist;
                                    });
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              _navigateToHomePage(context, media);
                            },
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  Timer? _debounceTimer;

  MovieSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      onSearch(query);
    });

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void showResults(BuildContext context) {
    close(context,
        query); // Close the search bar and pass the selected movie title
  }
}
