import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_movie_recommender_app/movie.dart';

import '../mediadetailspage.dart';
import '../user_ratings.dart';

class MoviesPage extends StatefulWidget {
  final String apiKey;
  final List<int> genreIds;
  final String genre;
  final List<Media> genreMedia;
  final List<Media> genreNames;
  final int selectedGenreId;

  const MoviesPage({
    Key? key,
    required this.apiKey,
    required this.genreIds,
    required this.genre,
    required this.genreMedia,
    required this.genreNames,
    required this.selectedGenreId,
  }) : super(key: key);

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late List<Media> _trendingMedia = [];
  late List<Media> _newReleaseMedia = [];
  late List<Media> _recommendedMedia = [];
  late List<Media> _searchedMedia = [];
  late List<Media> _upcomingMedia = [];
  late List<Media> _genreMedia = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedia();
    _updateGenreMedia(widget.genreMedia);
  }

  Future<void> _fetchMedia() async {
    await _fetchTrendingMedia();
    await _fetchNewReleaseMedia();
    await _fetchRecommendedMedia();
    await _fetchUpcomingMedia();
    await _fetchGenreMedia();
  }

  Future<void> _fetchTrendingMedia() async {
    final url =
        'https://api.themoviedb.org/3/trending/all/week?api_key=${widget.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      setState(() {
        _trendingMedia = media;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _fetchNewReleaseMedia() async {
    final url =
        'https://api.themoviedb.org/3/movie/now_playing?api_key=${widget.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      setState(() {
        _newReleaseMedia = media;
        _searchedMedia = List.from(_newReleaseMedia);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _fetchRecommendedMedia() async {
    final url =
        'https://api.themoviedb.org/3/discover/movie?api_key=${widget.apiKey}&sort_by=popularity.desc&with_genres=${widget.genreIds.join('%2C')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      setState(() {
        _recommendedMedia = media;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _fetchUpcomingMedia() async {
    final url =
        'https://api.themoviedb.org/3/movie/upcoming?api_key=${widget.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final media =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      setState(() {
        _upcomingMedia = media;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _fetchSimilarMedia(Media media) async {
    final url =
        'https://api.themoviedb.org/3/movie/${media.id}/similar?api_key=${widget.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final similarMedia =
          results.map((mediaData) => Media.fromJson(mediaData)).toList();
      media.similarMedia = similarMedia;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _fetchMediaDetails(Media media) async {
    final url =
        'https://api.themoviedb.org/3/movie/${media.id}?api_key=${widget.apiKey}';

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaDetailsPage(
            media: media,
            onRate: (double) {},
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
        'https://api.themoviedb.org/3/movie/$mediaId/credits?api_key=${widget.apiKey}';

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
          'https://api.themoviedb.org/3/discover/movie?api_key=${widget.apiKey}&with_genres=${widget.selectedGenreId}';

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
  void didUpdateWidget(MoviesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGenreId != widget.selectedGenreId) {
      _fetchGenreMedia();
    }
  }

  void _searchMedia(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        final searchedMedia = _newReleaseMedia
            .where((media) =>
                media.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        setState(() {
          _searchedMedia = searchedMedia;
        });
      } else {
        setState(() {
          _searchedMedia = List.from(_newReleaseMedia);
        });
      }
    });
  }

  // Function to update _genreMedia list based on the selected genre ID
  void _updateGenreMedia(List<Media> genreMedia) {
    setState(() {
      _genreMedia = genreMedia
          .where((media) => media.genreIds.contains(widget.selectedGenreId))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: unnecessary_null_comparison
        title: const Text('Movies & TV Shows'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: MediaSearch(
                  _searchController,
                  _searchMedia,
                  _searchedMedia,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Movies',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _genreMedia.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 250.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _genreMedia.length,
                      itemBuilder: (context, index) {
                        final media = _genreMedia[index];
                        return GestureDetector(
                          onTap: () => _fetchMediaDetails(
                              media), // Fetch media details and navigate
                          child: Container(
                            width: 150.0,
                            margin: const EdgeInsets.all(8.0),
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
                                const SizedBox(height: 8.0),
                                Text(
                                  media.title,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                RatingBar.builder(
                                  initialRating: media.rating,
                                  minRating: 1.0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            _buildSectionHeader('Trending Media'),
            _buildMediaList(_trendingMedia),
            _buildSectionHeader('New Releases'),
            _buildMediaList(_newReleaseMedia),
            _buildSectionHeader('Recommended Media'),
            _buildMediaList(_recommendedMedia),
            _buildSectionHeader('Upcoming Media'),
            _buildMediaList(_upcomingMedia),
            _buildSectionHeader('Search Results'),
            _buildMediaList(_searchedMedia),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMediaList(List<Media> mediaList) {
    // Filter the mediaList by the selected genreId
    final List<Media> filteredMedia = widget.genreIds.isEmpty
        ? mediaList
        : mediaList
            .where((media) => media.genreIds.contains(widget.genreIds[0]))
            .toList();

    return filteredMedia.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredMedia.length,
              itemBuilder: (BuildContext context, int index) {
                final media = filteredMedia[index];
                return GestureDetector(
                  onTap: () => _fetchMediaDetails(media),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.all(8.0),
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
                        const SizedBox(height: 8.0),
                        Text(
                          media.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        RatingBar.builder(
                          initialRating: media.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 1.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}

class MediaSearch extends SearchDelegate<String> {
  final TextEditingController searchController;
  final Function(String) searchMedia;
  final List<Media> searchedMedia;

  MediaSearch(this.searchController, this.searchMedia, this.searchedMedia);

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
    final resultList = searchedMedia
        .where(
            (media) => media.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: resultList.length,
      itemBuilder: (BuildContext context, int index) {
        final media = resultList[index];
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
    final suggestionList = searchedMedia
        .where(
            (media) => media.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int index) {
        final media = suggestionList[index];
        return ListTile(
          title: Text(media.title),
          onTap: () {
            close(context, media.title);
          },
        );
      },
    );
  }
}
