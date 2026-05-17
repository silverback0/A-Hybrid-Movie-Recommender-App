import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote_config_service.dart';

Future<List<dynamic>> fetchRecommendedMovies(
  String title,
) async {
  try {
    RemoteConfigService remoteConfigService =
        RemoteConfigService();

    await remoteConfigService.initialize();

    // Get complete API URL from Firebase
    String apiBaseUrl =
        remoteConfigService.apiBaseUrl;

    final encodedTitle =
        Uri.encodeQueryComponent(title);

    final recommendationsUrl = Uri.parse(
      '$apiBaseUrl/recommendations?title=$encodedTitle',
    );

    final response =
        await http.get(recommendationsUrl);

    if (response.statusCode == 200) {

      final decodedResponse =
          jsonDecode(response.body);

      return decodedResponse[
          'recommendations'];

    } else {

      throw Exception(
        'Failed to fetch recommendations '
        'Status: ${response.statusCode}'
      );
    }

  } catch (e) {

    print(
      'Error fetching recommended movies: $e'
    );

    return [];
  }
}