import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/widgets/awsome_material_banner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchAIResponse(String prompt) async {
  var url = Uri.parse('https://api.aimlapi.com/v1/chat/completions');
  var response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer ${dotenv.env['AkiraMenAIapi']}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "messages": [
        {"role": "system", "content": prompt, "name": "text"},
      ],
      'model': 'chatgpt-4o-latest', // Specify the model you want to use
    }),
  );

  if (response.statusCode == 201) {
    var data = jsonDecode(response.body);
    return data['choices'][0]['message']['content']; // Extract the AI response from the JSON data
  } else {
    throw Exception(
      'Failed to load AI response ${response.statusCode} ${response.body}',
    ); // Handle error response
  }
}
Future<String> extractDates(String text, BuildContext context) async {
  final String geminiApiKey =
      dotenv.env['GeminiApiKey']!; // Load the API key from environment variables
  final DateTime now = DateTime.now();
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=$geminiApiKey',
  );

  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({
    'contents': [
      {
        'parts': [
          {
            'text':
                'today is $now recognize any date available from the following message with the time if available : $text and respond with it only in the format YYYY-MM-DD HH:MM:SS , return null if no date is available',
          },
        ],
      },
    ],
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['candidates'][0]['content']['parts'][0]['text'];
    } else {
      if(!context.mounted) return "null";
      awesomeMaterialBanner(
        context: context,
        title: 'Error',
        message:
            'Failed to generate content. Status code: ${response.statusCode}',
        contentType: ContentType.failure,
      );
      return "null";
    }
  } catch (e) {
    awesomeMaterialBanner(
      context: context,
      title: 'Error',
      message: 'An error occurred: $e',
      contentType: ContentType.failure,
    );
    return "null";
  }
}
Future<String> generateContent(String text, BuildContext context) async {
  final String geminiApiKey =
      dotenv.env['GeminiApiKey']!; // Load the API key from environment variables
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=$geminiApiKey',
  );

  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({
    'contents': [
      {
        'parts': [
          {
            'text':
                text,
          },
        ],
      },
    ],
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['candidates'][0]['content']['parts'][0]['text'];
    } else {
      if(!context.mounted) return "null";
      awesomeMaterialBanner(
        context: context,
        title: 'Error',
        message:
            'Failed to generate content. Status code: ${response.statusCode}',
        contentType: ContentType.failure,
      );
      return "null";
    }
  } catch (e) {
    awesomeMaterialBanner(
      context: context,
      title: 'Error',
      message: 'An error occurred: $e',
      contentType: ContentType.failure,
    );
    return "null";
  }
}