import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  static Future<String?> fetchQuoteOfTheDay() async {
    final url = Uri.parse('https://zenquotes.io/api/today');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return "| ${data[0]['q']} ~ ${data[0]['a']}"; // The quote text
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
