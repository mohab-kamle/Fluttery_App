import 'package:flutter/material.dart';
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
        {"role": "user", "content": prompt, "name": "text"},
      ],
      'model': 'chatgpt-4o-latest', // Specify the model you want to use
    }),
  );

  if (response.statusCode == 201) {
    var data = jsonDecode(response.body);
    return data['content']; // Extract the AI response from the JSON data
  } else {
    print('Error: ${response.statusCode}'); // Print the error code
    print('Response: ${response.body}'); // Print the error response
    throw Exception('Failed to load AI response');
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String aiResponse = ""; // To store the AI response
  bool isLoading = false; // To manage loading state

  // Function to handle the button press
  Future<void> _getAIResponse() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      String response = await fetchAIResponse("what is 2 +3?");
      setState(() {
        aiResponse = response; // Update the UI with the result
      });
    } catch (e) {
      setState(() {
        aiResponse = "Error: $e"; // Display the error message if something goes wrong
      });
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Response Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the AI response or a loading indicator
            isLoading
                ? const CircularProgressIndicator()
                : Text(aiResponse),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _getAIResponse, // Call the function to get the response
              child: const Text("Click me"),
            ),
          ],
        ),
      ),
    );
  }
}
