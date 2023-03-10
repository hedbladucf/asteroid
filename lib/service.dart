import 'dart:convert';
import 'dart:developer';

import 'package:asteroid/models.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// NASA API Key needs to be defined as an env variable
// run the app with --dart-define=NASA_KEY=THE_KEY
const _apiKey = String.fromEnvironment('NASA_KEY');

final yMdFormat = DateFormat('yyyy-MM-dd');
final yMMMdFormat = DateFormat.yMMMd();

class AsteroidService {
  final _client = http.Client();

  Future<AsteroidModel> fetchAsteroids({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client.get(
        Uri.https(
          'api.nasa.gov',
          '/neo/rest/v1/feed',
          {
            'start_date': yMdFormat.format(startDate),
            'end_date': yMdFormat.format(endDate),
            'api_key': _apiKey,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error with code ${response.statusCode}');
      }

      return AsteroidModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
