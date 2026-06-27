import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PredictionResult {
  final String disease;
  final double confidence;
  final bool isHealthy;
  final String severity;
  final String description;
  final String treatment;
  final String prevention;
  final Map<String, dynamic> allClassProbabilities;

  PredictionResult({
    required this.disease,
    required this.confidence,
    required this.isHealthy,
    required this.severity,
    required this.description,
    required this.treatment,
    required this.prevention,
    required this.allClassProbabilities,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      disease: json['disease'] ?? 'Unknown',
      confidence: (json['confidence'] as num).toDouble(),
      isHealthy: json['is_healthy'] ?? false,
      severity: json['severity'] ?? 'Unknown',
      description: json['description'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      allClassProbabilities:
          Map<String, dynamic>.from(json['all_class_probabilities'] ?? {}),
    );
  }
}

class ApiService {
  // ⚠️ The Render free tier cold-starts after inactivity (~30–60s first request)
  static const String _baseUrl =
      'https://maize-leaf-disease-backend.onrender.com';

  static Future<PredictionResult> predictDisease(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/predict');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    // Long timeout because Render free tier may need 30–60s to cold-start
    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PredictionResult.fromJson(json);
    } else {
      throw Exception(
          'Prediction failed (${response.statusCode}): ${response.body}');
    }
  }

  /// Optional: ping the server on app launch to warm it up
  static Future<bool> ping() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
