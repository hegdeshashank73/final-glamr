// lib/services/api_service.dart

import 'dart:typed_data';


import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> getUploadUrl() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assets/upload'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "entity_type": "clothing",
          "content_type": "image/jpeg"
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get upload URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting upload URL: $e');
    }
  }

  Future<void> uploadImageToS3(String uploadUrl, Uint8List imageBytes) async {
    try {
      final response = await http.put(
        Uri.parse(uploadUrl),
        body: imageBytes,
        headers: {'Content-Type': 'image/jpeg'}, // Content type has to be made dynamic
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<Map<String, dynamic>> searchOptions(String s3Key) async {
    try {
      final queryParameters = {
        's3_key': s3Key,
        'country': 'us'
      };
      final uri = Uri.parse('$baseUrl/search/options')

          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get search options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting search options: $e');
    }
  }
}