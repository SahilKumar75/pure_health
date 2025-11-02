import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/ml_constants.dart';

class MLApiClient {
  static const String _tag = 'MLApiClient';
  final http.Client httpClient;

  MLApiClient({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${MLConstants.baseUrl}$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      final response = await httpClient
          .post(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(MLConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${MLConstants.baseUrl}$endpoint');
      final defaultHeaders = {
        'Accept': 'application/json',
        ...?headers,
      };

      final response = await httpClient
          .get(url, headers: defaultHeaders)
          .timeout(MLConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'API Error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
