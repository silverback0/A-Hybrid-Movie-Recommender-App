import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_movie_recommender_app/firestore_service.dart';
import 'package:my_movie_recommender_app/screens/RecommendedMoviesScreen.dart';
import 'package:my_movie_recommender_app/screens/home_page.dart';

import 'package:my_movie_recommender_app/screens/movies_page.dart';
import 'authentication_service.dart';
import 'movie.dart';
import 'userprofile.dart';

import '../api_key.dart';
import '../screens/profile_page.dart';
import '../screens/sign_in_page.dart';
import '../screens/watchlist_screen.dart';
import '../remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirestoreService firestoreService = FirestoreService.instance;
  await createCollections();
  RemoteConfigService remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  runApp(const MyApp());
}

Future<void> createCollections() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference<Map<String, dynamic>> mediaCollectionRef =
        firestore.collection('media');

    // Make an API call to retrieve movie data from TMDB
    final moviesResponse = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=c9c9330b67b52b7f6820d62d28187fb1'));
    if (moviesResponse.statusCode == 200) {
      final moviesData = json.decode(moviesResponse.body);
      final movies = moviesData['results'];

      // Create the 'media' collection and populate with movie data
      for (var movie in movies) {
        // Save the movie data with additional fields
        await mediaCollectionRef.add({
          'type': 'movie',
          'title': movie['title'],
          'overview': movie['overview'],
          'posterUrl': movie['poster_path'],
          'releaseDate': movie['release_date'],
          'voteAverage': movie['vote_average'],
          'popularity': movie['popularity'],
          'cast': movie['cast'],
          'genre': movie['genre_ids']
        });
      }
    } else {
      print('Failed to fetch movies from TMDB');
    }
    final CollectionReference userProfilesCollection =
        FirebaseFirestore.instance.collection('userProfiles');

    print('Collections created and populated successfully');
  } catch (e) {
    print('Error creating collections: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const AuthWrapper(),
        '/movieDetails': (context) => const MovieDetailsRoute(),
        '/watchlist': (context) => WatchlistScreen(
              watchlist: const [],
              onAddToWatchlist: (media) {},
            ),
        '/movies': (context) => const MoviesPage(
            apiKey: apiKey,
            genre: '',
            genreIds: [],
            genreMedia: [],
            genreNames: [],
            selectedGenreId: 0),
        '/profile': (context) => ProfilePage(
              userProfile: UserProfile(uid: '', email: '', name: ''),
            ),
        '/editProfile': (context) => const EditProfilePage(
              name: '',
            ),
        '/recommendedMovies': (context) => const RecommendedMoviesScreen(
              watchlist: [],
            ),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthenticationService _auth =
      AuthenticationService(FirebaseAuth.instance, UserProfileService());

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges.listen((User? user) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user != null) {
      return const MyHomePage();
    } else {
      return const SignInPage();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  AuthenticationService get _auth =>
      AuthenticationService(FirebaseAuth.instance, UserProfileService());

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const MoviesPage(
      apiKey: apiKey,
      genre: '',
      genreIds: [],
      genreMedia: [],
      genreNames: [],
      selectedGenreId: 0,
    ),
    const RecommendedMoviesScreen(
      watchlist: [],
    ),
    ProfilePage(
      userProfile: UserProfile(email: '', name: '', uid: ''),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<String, dynamic>> fetchContent(
      String endpoint, String genre) async {
    const apiKey = 'c9c9330b67b52b7f6820d62d28187fb1';
    final url =
        'https://api.themoviedb.org/3/$endpoint?api_key=$apiKey&with_genres=$genre';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch $endpoint');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => widget._auth.signOut(),
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.movie),
                label: 'Movies',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_border_purple500),
                label: 'Recommended',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: _onItemTapped));
  }
}

class MovieDetailsRoute extends StatelessWidget {
  const MovieDetailsRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Media media = ModalRoute.of(context)!.settings.arguments as Media;

    return Scaffold(
      appBar: AppBar(
        title: Text(media.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title: ${media.title}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Release Date: ${media.releaseDate}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Overview: ${media.overview}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
