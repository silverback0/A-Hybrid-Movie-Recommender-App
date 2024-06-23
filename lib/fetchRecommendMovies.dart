import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote_config_service.dart';

Future<List<dynamic>> fetchRecommendedMovies(
  String title,
) async {
  try {
    RemoteConfigService remoteConfigService = RemoteConfigService();
    await remoteConfigService.initialize();

    String ipAddress = remoteConfigService.flaskIpAddress;

    // Encode the title parameter properly to handle spaces and special characters
    final encodedTitle = Uri.encodeQueryComponent(title);

    // Construct the base URL
    final baseUrl = 'http://$ipAddress:5000/recommendations';

    // Modify the URL to include the query title and year if available
    final recommendationsUrl = Uri.parse('$baseUrl?title=$encodedTitle');

    final recommendationsResponse = await http.get(recommendationsUrl);
    if (recommendationsResponse.statusCode == 200) {
      final List<dynamic> recommendedMovies =
          jsonDecode(recommendationsResponse.body);
      return recommendedMovies;
    } else {
      throw Exception('Failed to fetch recommendations');
    }
  } catch (e) {
    print('Error fetching recommended movies: $e');
    return [];
  }
}
