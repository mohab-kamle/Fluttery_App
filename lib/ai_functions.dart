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
    throw Exception('Failed to load AI response ${response.statusCode} ${response.body}'); // Handle error response
  }
}