import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  static const String _apiKey = 'AIzaSyCOr5m4RkAoob-uzQMSj7xNkBFfjCdWcNE';

  Future<Map<String, dynamic>?> analyzeImage(XFile imageFile) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = 'You are an urban drainage expert. Analyze this image. If it is NOT a drain, return {"is_drain": false}. If it IS a drain, return ONLY the JSON object, no introductory text, no markdown styling. Format: {"is_drain": true, "severity": "Low/Medium/High", "debris": "string description", "percentage": int}.';
      
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final content = [
        Content.multi([TextPart(prompt), imagePart])
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      print('--- RAW GEMINI RESPONSE ---');
      print(text);
      print('---------------------------');

      if (text != null) {
        // Find JSON boundaries just in case there are markdown code blocks
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = text.substring(jsonStart, jsonEnd);
          try {
            return jsonDecode(jsonString);
          } catch (parseError) {
            print('JSON Parsing Error: $parseError');
            print('Attempted to parse: $jsonString');
            return null;
          }
        } else {
          print('Error: No JSON boundaries found in the response.');
        }
      }
      return null;
    } catch (e) {
      print('General Error in AIService: $e');
      return null;
    }
  }
}
