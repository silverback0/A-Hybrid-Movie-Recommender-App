import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my_movie_recommender_app/movie.dart';
import '../api_key.dart';
import '../authentication_service.dart';
import '../mediadetailspage.dart';
import '../user_ratings.dart';
import '../userprofile.dart';
import 'moviegenres.dart';
import 'watchlist_screen.dart';
import 'similarmediascreen.dart';

// import'moviedetails.dart';

class HomePage extends StatefulWidget {
  final dynamic
      media; // Receive the 'media' data from the RecommendedMoviesScreen
  const HomePage({Key? key, this.media}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthenticationService _authService =
      AuthenticationService(FirebaseAuth.instance, UserProfileService());
  final List<Media> _allMedia = [];
  List<Media> _trendingMedia = [];
  List<Media> _newReleaseMedia = [];
  List<Media> _recommendedMedia = [];
  List<Media> _searchedMedia = [];
  final TextEditingController _searchController = TextEditingController();
  List<Media> _watchlist = [];
  int? _selectedGenreId;

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  final List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'TV Movie',
    'Thriller',
    'War',
    'Western',
  ];

  Future<void> fetchMedia() async {
    const apiKey =
        'c9c9330b67b52b7f6820d62d28187fb1'; // Replace with your TMDB API key
    const trendingUrl =
        'https://api.themoviedb.org/3/trending/all/day?api_key=$apiKey';
    const newReleaseUrl =
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey';
    var query;
    final searchUrl =
        'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query';
    await fetchTrendingMedia(trendingUrl);
    await fetchNewReleaseMedia(newReleaseUrl);
    await fetchRecommendedMedia();
    await fetchSearchResults(searchUrl);
  }

  Future<void> fetchSearchResults(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media = results.map((mediaData) {
        final media = Media.fromJson(mediaData);
        media.genreNames = fetchGenreNames(media.genreIds);
        return media;
      }).toList();

      setState(() {
        _searchedMedia = media;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> fetchTrendingMedia(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media = results.map((mediaData) {
        final media = Media.fromJson(mediaData);
        media.genreNames = fetchGenreNames(media.genreIds);
        return media;
      }).toList();

      if (_selectedGenreId != null) {
        media.retainWhere((media) => media.genreIds.contains(_selectedGenreId));
      }
      setState(() {
        _trendingMedia = media;
        _allMedia.addAll(media);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> fetchNewReleaseMedia(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media = results.map((mediaData) {
        final media = Media.fromJson(mediaData);
        media.genreNames = fetchGenreNames(media.genreIds);
        return media;
      }).toList();
      if (_selectedGenreId != null) {
        media.retainWhere((media) => media.genreIds.contains(_selectedGenreId));
      }
      setState(() {
        _newReleaseMedia = media;
        _allMedia.addAll(media);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  // Update the _handleUserRating method to take the Media parameter as well
  void _handleUserRating(Media media, double rating) {
    setState(() {
      // Find the media in _recommendedMedia, _trendingMedia, or _newReleaseMedia and update the user rating
      final List<Media> allMedia = [
        ..._recommendedMedia,
        ..._trendingMedia,
        ..._newReleaseMedia
      ];
      final foundMedia = allMedia.firstWhere((item) => item.id == media.id,
          orElse: () => media);
      foundMedia.userRating = rating;
    });
  }

  Future<void> _fetchMediaDetails(Media media) async {
    final url =
        'https://api.themoviedb.org/3/movie/${media.id}?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final castData = await _fetchCastData(media.id);

      media.cast = castData['cast'];
      media.characters = castData['characters'];
      media.description = data['overview'];

      // Fetch similar movies
      await _fetchSimilarMedia(media);

      // Navigate to MediaDetailsPage with the updated media object
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaDetailsPage(
            media: media,
            onRate: (double rating) => _handleUserRating(media, rating),
            ratingsService: UserRatingsService(),
          ),
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<Map<String, dynamic>> _fetchCastData(int mediaId) async {
    final url =
        'https://api.themoviedb.org/3/movie/$mediaId/credits?api_key=c9c9330b67b52b7f6820d62d28187fb1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final cast = data['cast'] as List<dynamic>;

      final List<String> castMembers = [];
      final List<String> characters = [];

      for (final actor in cast.take(5)) {
        castMembers.add(actor['name']);
        characters.add(actor['character']);
      }

      return {'cast': castMembers, 'characters': characters};
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {'cast': [], 'characters': []};
    }
  }

  // Method to sort the recommended media based on user ratings
  List<Media> _sortRecommendedMedia(List<Media> mediaList) {
    // Sort the mediaList in descending order based on user ratings
    mediaList.sort((a, b) => b.userRating.compareTo(a.userRating));
    return mediaList;
  }

  Future<void> fetchRecommendedMedia() async {
    final List<Media> recommendedMedia = [];
    final random = Random();
    for (int i = 0; i < 9; i++) {
      final randomIndex = random.nextInt(_allMedia.length);
      recommendedMedia.add(_allMedia[randomIndex]);
    }
    setState(() {
      _recommendedMedia = _sortRecommendedMedia(recommendedMedia);
    });
  }

  Future<void> _fetchSimilarMedia(Media media) async {
    const apiKey = 'c9c9330b67b52b7f6820d62d28187fb1';
    final url =
        'https://api.themoviedb.org/3/movie/${media.id}/similar?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final similarMedia =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      media.similarMedia = similarMedia;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimilarMediaScreen(
            similarMedia: similarMedia,
          ),
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _searchMedia({required String query}) async {
    if (query.isNotEmpty) {
      const apiKey = 'c9c9330b67b52b7f6820d62d28187fb1';
      final searchUrl =
          'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query';

      try {
        final response = await http.get(Uri.parse(searchUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List<dynamic>;
          final searchedMedia = results.map((mediaData) {
            final media = Media.fromJson(mediaData);
            media.genreNames = fetchGenreNames(media.genreIds);
            return media;
          }).toList();

          setState(() {
            _searchedMedia = searchedMedia;
          });
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (error) {
        print('Error during API request: $error');
      }
    } else {
      setState(() {
        _searchedMedia = [];
      });
    }
  }

  void onQueryChanged(String query) {
    _searchMedia(query: query);
  }

  void _navigateToMovieGenres(int genreId, String genreName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieGenres(
          apiKey:
              'c9c9330b67b52b7f6820d62d28187fb1', // Replace with your API key
          selectedGenreId: genreId,
          genreName: genreName,
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToWatchlist() async {
    final updatedWatchlist = await Navigator.push<List<Media>>(
      context,
      MaterialPageRoute(
        builder: (context) => WatchlistScreen(
          watchlist: _watchlist,
          onAddToWatchlist: _addToWatchlist,
        ),
      ),
    );

    // Check if updatedWatchlist is not null, which means it was returned with data
    if (updatedWatchlist != null) {
      setState(() {
        _watchlist = updatedWatchlist;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToWatchlist(Media media) {
    // Check if the media is already in the watchlist
    if (!_watchlist.contains(media)) {
      setState(() {
        _watchlist.add(media);
      });
    }
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

  // Method to get the genre ID based on its name
  int _getGenreIdFromName(String genreName) {
    final genres = {
      'Action': 28,
      'Adventure': 12,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Fantasy': 14,
      'History': 36,
      'Horror': 27,
      'Music': 10402,
      'Mystery': 9648,
      'Romance': 10749,
      'Science Fiction': 878,
      'TV Movie': 10770,
      'Thriller': 53,
      'War': 10752,
      'Western': 37,
    };

    return genres[genreName] ??
        0; // Return 0 as a default value if the genre name is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies & TV Shows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _navigateToWatchlist,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: onQueryChanged,
              ),
            ),
            const SizedBox(height: 16.0),
            if (_searchedMedia.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8.0),
            if (_searchedMedia.isNotEmpty)
              SizedBox(
                height: 250.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _searchedMedia.length,
                  itemBuilder: (context, index) {
                    final media = _searchedMedia[index];
                    print('Building Item: $media');
                    return MediaCard(
                      media: media,
                      onAddToWatchlist: _addToWatchlist,
                      fetchSimilarMedia: _fetchSimilarMedia,
                      fetchMediaDetails: _fetchMediaDetails,
                      onRate: (double rating) =>
                          _handleUserRating(media, rating),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trending',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _trendingMedia.length,
                itemBuilder: (context, index) {
                  final media = _trendingMedia[index];
                  if (_selectedGenreId == null ||
                      media.genreIds.contains(_selectedGenreId)) {
                    return MediaCard(
                      media: media,
                      onAddToWatchlist: _addToWatchlist,
                      fetchSimilarMedia: _fetchSimilarMedia,
                      fetchMediaDetails: _fetchMediaDetails,
                      onRate: (double rating) =>
                          _handleUserRating(media, rating),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'New Releases',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _newReleaseMedia.length,
                itemBuilder: (context, index) {
                  final media = _newReleaseMedia[index];
                  if (_selectedGenreId == null ||
                      media.genreIds.contains(_selectedGenreId)) {
                    return MediaCard(
                      media: media,
                      onAddToWatchlist: _addToWatchlist,
                      fetchSimilarMedia: _fetchSimilarMedia,
                      fetchMediaDetails: _fetchMediaDetails,
                      onRate: (double rating) =>
                          _handleUserRating(media, rating),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedMedia.length,
                itemBuilder: (context, index) {
                  final media = _recommendedMedia[index];
                  if (_selectedGenreId == null ||
                      media.genreIds.contains(_selectedGenreId)) {
                    return MediaCard(
                      media: media,
                      onAddToWatchlist: _addToWatchlist,
                      fetchSimilarMedia: _fetchSimilarMedia,
                      fetchMediaDetails: _fetchMediaDetails,
                      onRate: (double rating) =>
                          _handleUserRating(media, rating),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Genres',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 40.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  final genreId = _getGenreIdFromName(genre);

                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () => _navigateToMovieGenres(
                            genreId, genre), // Pass the genre media list here
                        child: ElevatedButton(
                          onPressed: () =>
                              _navigateToMovieGenres(genreId, genre),
                          child: Text(genre),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaSearch extends SearchDelegate<String> {
  final TextEditingController searchController;
  final Function(String) searchMedia;
  final List<Media> searchedMedia;

  MediaSearch({
    required this.searchController,
    required this.searchMedia,
    required this.searchedMedia,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          searchController.clear();
          searchMedia('');
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: searchedMedia.length,
      itemBuilder: (BuildContext context, int index) {
        final media = searchedMedia[index];

        return ListTile(
          title: Text(media.title),
          onTap: () {
            close(context, media.title);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          title: Text('Search for movies and TV shows'),
          leading: Icon(Icons.search),
        ),
      ],
    );
  }
}

class MediaCard extends StatelessWidget {
  final Media media;
  final Function(Media) onAddToWatchlist;
  final Function(Media) fetchMediaDetails;
  final Function(double) onRate; // New parameter

  const MediaCard({
    Key? key,
    required this.media,
    required this.onAddToWatchlist,
    required Future<void> Function(Media media) fetchSimilarMedia,
    required this.fetchMediaDetails,
    required this.onRate,
  }) : super(key: key);

  // Function to update the user rating for the media
  void _updateUserRating(double rating) {
    // Call the onRate callback to pass the rating back to HomePage
    onRate(rating);
  }

  void _onCardTap(BuildContext context) async {
    // Fetch media details
    await fetchMediaDetails(media);

    // Navigate to MediaDetailsPage
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaDetailsPage(
          media: media,
          onRate: _updateUserRating,
          ratingsService: UserRatingsService(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          onTap: () =>
              _onCardTap(context), // Call _onCardTap when the card is tapped
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    media.posterUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.title,
                      maxLines: 2, // Limit the title to 2 lines
                      overflow: TextOverflow
                          .ellipsis, // Show ellipsis if text overflows
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Rating: ${media.rating}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Rating: ${media.userRating}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Add to Watchlist'),
                                  content: const Text(
                                    'This media item will be added to your watchlist.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        onAddToWatchlist(media);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.bookmark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
