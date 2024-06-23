import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_movie_recommender_app/mediadetailspage.dart';
import 'package:my_movie_recommender_app/movie.dart';

import '../user_ratings.dart';

class WatchlistScreen extends StatefulWidget {
  final List<Media> watchlist;
  final Function(Media) onAddToWatchlist;

  const WatchlistScreen({
    Key? key,
    required this.watchlist,
    required this.onAddToWatchlist,
  }) : super(key: key);

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // Use the local _watchlist variable to hold the media in the watchlist
  List<Media> _watchlist = [];

  // Function to save the watchlist to shared preferences
  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = _watchlist.map((media) => media.toJson()).toList();
    await prefs.setStringList('watchlist', List<String>.from(watchlistJson));
  }

  // Function to load the watchlist from shared preferences
  Future<void> _loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = prefs.getStringList('watchlist');
    if (watchlistJson != null) {
      final watchlist = watchlistJson
          .map((json) => Media.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _watchlist.addAll(watchlist);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the watchlist when the screen is initialized
    _watchlist = widget.watchlist;
  }

  // Function to remove media from the watchlist
  void _removeFromWatchlist(int index) {
    setState(() {
      _watchlist.removeAt(index);
      // Save the updated watchlist after removing an item
      _saveWatchlist();
    });
  }

  // Function to mark media as watched
  void _markAsWatched(int index) {
    setState(() {
      _watchlist[index].watched = true;
      widget.onAddToWatchlist(_watchlist[index]);
      // Save the updated watchlist after marking as watched
      _saveWatchlist();
    });
  }

  // Function to handle rating updates from the MediaDetailsPage
  void _updateUserRating(Media media, double rating) {
    setState(() {
      // Find the index of the media in the watchlist
      int index = _watchlist.indexOf(media);
      if (index != -1) {
        // Update the rating of the media in the watchlist
        _watchlist[index].rating = rating;
        // Save the updated watchlist after updating the rating
        _saveWatchlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
      ),
      body: _watchlist.isEmpty
          ? const Center(
              child: Text('Your watchlist is empty.'),
            )
          : ListView.builder(
              itemCount: _watchlist.length, // Use the local _watchlist here
              itemBuilder: (context, index) {
                final media =
                    _watchlist[index]; // Use the local _watchlist here
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w92${media.posterPath}',
                  ),
                  title: Text(media.title),
                  subtitle: Text(
                    'Released: ${media.releaseDate.year}\nRating: ${media.voteAverage}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          _markAsWatched(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _removeFromWatchlist(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    // Wait for the user to rate the movie
                    double? rating = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaDetailsPage(
                          media: media,
                          onRate: (rating) => _updateUserRating(media, rating),
                          ratingsService: UserRatingsService(),
                        ),
                      ),
                    );
                    // If the user rated the movie, update the rating
                    if (rating != null) {
                      _updateUserRating(media, rating);
                    }
                  },
                );
              },
            ),
    );
  }
}
