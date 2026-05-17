import 'dart:async';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import '../fetchRecommendMovies.dart';
import '../movie.dart';
import 'home_page.dart';

class RecommendedMoviesScreen extends StatefulWidget {
  final List<Media> watchlist;

  const RecommendedMoviesScreen({
    Key? key,
    required this.watchlist,
  }) : super(key: key);

  @override
  _RecommendedMoviesScreenState createState() =>
      _RecommendedMoviesScreenState();
}

class _RecommendedMoviesScreenState
    extends State<RecommendedMoviesScreen> {

  String? _selectedMovie;
  Future<List<dynamic>>? _recommendedMoviesFuture;

  void _onSearch(String movieTitle) {
    setState(() {
      _selectedMovie = movieTitle;
    });

    _loadRecommendedMovies(movieTitle);
  }

  void _loadRecommendedMovies(
      String movieTitle) async {

    try {

      List<dynamic> recommendedMovies =
          await fetchRecommendedMovies(
        movieTitle,
      );

      setState(() {
        _recommendedMoviesFuture =
            Future.value(
                recommendedMovies);
      });

    } catch (e) {

      setState(() {
        _recommendedMoviesFuture =
            Future.error(
          'Error fetching recommended movies: $e',
        );
      });

    }
  }

  void _navigateToHomePage(
      BuildContext context,
      dynamic media) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomePage(
          media: media,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: _selectedMovie == null
            ? const Text(
                'Recommended Movies')
            : Text(
                'Recommended Movies for $_selectedMovie'),

        actions: [

          IconButton(
            icon:
                const Icon(Icons.search),

            onPressed: () {

              showSearch(
                context: context,
                delegate:
                    MovieSearchDelegate(
                  onSearch:
                      _onSearch,
                ),
              );

            },
          ),

        ],
      ),

      body: Center(

        child: _selectedMovie == null

            ? const Center(
                child: Text(
                  'Please search a movie to get recommendations.',
                ),
              )

            : _recommendedMoviesFuture ==
                    null

                ? const CircularProgressIndicator()

                : FutureBuilder<
                    List<dynamic>>(

                    future:
                        _recommendedMoviesFuture,

                    builder:
                        (context,
                            snapshot) {

                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {

                        return const CircularProgressIndicator();

                      }

                      if (snapshot
                          .hasError) {

                        return Text(
                          'Error loading recommended movies: ${snapshot.error}',
                        );

                      }

                      if (!snapshot
                              .hasData ||
                          snapshot
                              .data!
                              .isEmpty) {

                        return const Text(
                          'No recommended movies found.',
                        );

                      }

                      final recommendedMovies =
                          snapshot.data!;

                      return ListView.builder(

                        itemCount:
                            recommendedMovies.length,

                        itemBuilder:
                            (context,
                                index) {

                          final media =
                              recommendedMovies[
                                  index];

                          final title =
                              media[
                                      'title'] ??
                                  '';

                          final posterUrl =
                              media[
                                  'poster_url'];

                          final genres =
                              media[
                                      'genres'] ??
                                  [];

                          double rating =
                              (media[
                                          'rating'] ??
                                      0.0)
                                  .toDouble();

                          bool isAddedToWatchlist =
                              media[
                                      'isAddedToWatchlist'] ??
                                  false;

                          return ListTile(

                            title:
                                Text(
                              title,
                            ),

                            subtitle:
                                Text(
                              genres.join(
                                  ", "),
                            ),

                            leading:
                                posterUrl !=
                                        null

                                    ? Image.network(
                                        posterUrl,
                                        width:
                                            50,

                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {

                                          return const Icon(
                                            Icons.movie,
                                          );

                                        },
                                      )

                                    : const Icon(
                                        Icons.movie,
                                      ),

                            trailing:
                                Row(

                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [

                                RatingBar
                                    .builder(

                                  initialRating:
                                      rating,

                                  minRating:
                                      0,

                                  direction:
                                      Axis.horizontal,

                                  allowHalfRating:
                                      true,

                                  itemCount:
                                      5,

                                  itemSize:
                                      20,

                                  itemBuilder:
                                      (
                                    context,
                                    _,
                                  ) {

                                    return const Icon(
                                      Icons
                                          .star,
                                      color: Colors
                                          .amber,
                                    );

                                  },

                                  onRatingUpdate:
                                      (
                                    newRating,
                                  ) {

                                    setState(
                                        () {

                                      media[
                                              'rating'] =
                                          newRating;

                                    });

                                  },

                                ),

                                IconButton(

                                  icon:
                                      Icon(

                                    isAddedToWatchlist
                                        ? Icons
                                            .check_box
                                        : Icons
                                            .add_box,

                                    color:
                                        isAddedToWatchlist
                                            ? Colors.green
                                            : null,

                                  ),

                                  onPressed:
                                      () {

                                    setState(
                                        () {

                                      media['isAddedToWatchlist'] =
                                          !isAddedToWatchlist;

                                    });

                                  },

                                ),

                              ],

                            ),

                            onTap: () {

                              _navigateToHomePage(
                                context,
                                media,
                              );

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

class MovieSearchDelegate
    extends SearchDelegate<String> {

  final Function(String)
      onSearch;

  Timer? _debounceTimer;

  MovieSearchDelegate({
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(
      BuildContext context) {

    return [

      IconButton(

        icon:
            const Icon(Icons.clear),

        onPressed: () {

          query = '';

        },

      )

    ];

  }

  @override
  Widget buildLeading(
      BuildContext context) {

    return IconButton(

      icon:
          const Icon(Icons.arrow_back),

      onPressed: () {

        close(
            context,
            '');

      },

    );

  }

  @override
  Widget buildResults(
      BuildContext context) {

    onSearch(query);

    return const SizedBox.shrink();

  }

  @override
  Widget buildSuggestions(
      BuildContext context) {

    if (_debounceTimer != null &&
        _debounceTimer!.isActive) {

      _debounceTimer!
          .cancel();

    }

    _debounceTimer =
        Timer(

      const Duration(
          milliseconds: 500),

      () {

        onSearch(query);

      },

    );

    return const Center(
      child:
          CircularProgressIndicator(),
    );

  }

  @override
  void showResults(
      BuildContext context) {

    close(
      context,
      query,
    );

  }

}