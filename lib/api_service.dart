import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = "c9c9330b67b52b7f6820d62d28187fb1";
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
