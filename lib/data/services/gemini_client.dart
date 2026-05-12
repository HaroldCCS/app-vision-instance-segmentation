import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  final GenerativeModel _model;

  GeminiClient(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  /// Petición asíncrona a Gemini para que devuelva el nombre y la descripción en JSON.
  Future<Map<String, String>> analyzeObject(Uint8List imageBytes, String label) async {
    final prompt = '''
    Basado en la siguiente etiqueta detectada por un sistema de visión artificial ($label) y la imagen adjunta, 
    identifica qué objeto es probablemente y proporciona:
    1. Un único nombre conciso para el objeto (en español).
    2. Una descripción técnica/funcional breve (máximo 2 frases) del objeto.

    Responde ESTRICTAMENTE en formato JSON con las llaves: "nombre" y "descripcion".
    ''';

    final imageParts = [
      DataPart('image/png', imageBytes),
    ];

    try {
      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), ...imageParts])
      ]);

      final responseText = response.text ?? '';
      
      // Sanitizar bloques markdown de la respuesta si es necesario.
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      return {
        'nombre': data['nombre']?.toString() ?? 'Desconocido',
        'descripcion': data['descripcion']?.toString() ?? 'Sin descripción',
      };
    } catch (e) {
      return {
        'nombre': 'Error',
        'descripcion': 'Error en el API Client: \$e',
      };
    }
  }
}
