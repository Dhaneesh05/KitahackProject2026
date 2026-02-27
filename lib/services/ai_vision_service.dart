import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class AiVisionService {
  static final AiVisionService _instance = AiVisionService._internal();

  factory AiVisionService() {
    return _instance;
  }

  AiVisionService._internal();

  /// Analyzes a drain image using Gemini Vision to determine severity and material blockage.
  Future<Map<String, dynamic>> analyzeDrainImage(XFile imageFile) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
        throw Exception('GEMINI_API_KEY is missing or invalid in .env file.');
      }

      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: apiKey,
      );

      final prompt = '''You are an expert civil engineer AI. Analyze the image to see if it shows any kind of urban drainage, gutter, street, pipe, or water channel. Even if it's flooded or heavily blocked, consider it a valid drain. 
If absolutely no drain or street context exists, output: {"severity": "Error", "material": "Invalid"}. 
Otherwise, estimate the blockage and output ONLY valid JSON. 
Example 1 (Clean water): {"severity": "Low", "material": "Clear"}. 
Example 2 (Plastic bottles/Trash): {"severity": "High", "material": "Trash"}. 
Example 3 (Mud/Dirt/Silt): {"severity": "Medium", "material": "Silt"}.
Example 4 (Leaves/Branches): {"severity": "Medium", "material": "Vegetation"}.''';

      // Read the file bytes directly, which works on both Web and Mobile for XFile
      final imageBytes = await imageFile.readAsBytes();
      
      // Determine basic mime type from extension
      String mimeType = 'image/jpeg';
      if (imageFile.name.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }

      final imagePart = DataPart(mimeType, imageBytes);
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      final text = response.text;
      if (text == null) {
         throw Exception('Received empty response from Gemini');
      }

      // Sometimes Gemini wraps JSON in markdown blocks. Strip them.
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final parsed = jsonDecode(cleanText) as Map<String, dynamic>;
      return parsed;

    } catch (e) {
      // Catch any exceptions (like format parsing or API errors)
      return {
        "severity": "Error",
        "material": e.toString().length > 50 ? '${e.toString().substring(0, 50)}...' : e.toString()
      };
    }
  }

  /// Generates a concise safety summary explaining why a specific material blockage is dangerous.
  Future<String> generateReportSummary(String material) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
        throw Exception('GEMINI_API_KEY is missing or invalid in .env file.');
      }

      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: apiKey,
      );

      final prompt = '''You are a civil engineering AI assistant. In exactly 2 sentences, explain why a drainage blockage caused by '$material' is dangerous for flash floods. Be direct and concise with no markdown.''';

      final response = await model.generateContent([
        Content.text(prompt)
      ]);

      return response.text?.trim() ?? 'Summary generation failed.';
    } catch (e) {
      return 'Summary unavailable at this time due to a network or API error. Please try again later.';
    }
  }
}
