import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String baseUrl = "https://api.themoviedb.org/3";

  Future<http.Response> fetchMediaDetails(String mediaTitle) {
    final url = Uri.parse(
      "$baseUrl/search/multi?api_key=$apiKey&query=${mediaTitle.replaceAll(" ", "+")}",
    );
    return http.get(url);
  }

  Future<http.Response> fetchRecommendedMedia(String mediaId) {
    final url = Uri.parse(
      "$baseUrl/$mediaId/recommendations?api_key=$apiKey",
    );
    return http.get(url);
  }
}
