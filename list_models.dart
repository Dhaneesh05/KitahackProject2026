// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = '***REMOVED***'; // Actual Gemini API Key
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  if (response.statusCode == 200) {
    final data = jsonDecode(responseBody);
    final models = data['models'] as List;
    print('Available Models:');
    for (var model in models) {
      print('- ${model['name']}');
    }
  } else {
    print('Error ${response.statusCode}: $responseBody');
  }
}
