import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

  final String baseUrl = "https://maize-leaf-disease-backend.onrender.com";

  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      print("📤 Sending image to backend...");
      print("Path: ${imageFile.path}");

      FormData formData = FormData.fromMap({
        // ⚠️ BACKEND EXPECTS THIS EXACT KEY
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: "leaf.jpg",
        ),
      });

      final response = await dio.post(
        "$baseUrl/predict",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
        ),
      );

      print("✅ SUCCESS RESPONSE:");
      print(response.data);

      return response.data;
    } on DioException catch (e) {
      print("❌ STATUS: ${e.response?.statusCode}");
      print("❌ DATA: ${e.response?.data}");
      print("❌ MESSAGE: ${e.message}");

      throw Exception(
        e.response?.data ?? "Prediction failed. Check backend.",
      );
    }
  }
}
