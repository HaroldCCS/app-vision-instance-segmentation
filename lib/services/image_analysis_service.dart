import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ImageAnalysisService {
  static const String _endpoint =
      'https://us-central1-arquitectura-limpia-v1.cloudfunctions.net/analyzeImage';

  Future<AnalysisResult> analyzeImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AnalysisResult.fromJson(json);
    } else {
      throw Exception(
          'Error al analizar la imagen: ${response.statusCode} - ${response.body}');
    }
  }
}
