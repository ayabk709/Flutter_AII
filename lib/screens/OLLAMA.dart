import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  // Replace with the actual endpoint and port where Ollama is running
  static const String baseUrl = "http://192.168.1.7:11434/api/generate";
 // Replace with actual port

  // Function to get a response from the llama3 model
  Future<String> getLlamaResponse(String query) async {
    final url = Uri.parse(baseUrl);

    // Prepare the request body (adjust according to Ollama's requirements)
    final body = json.encode({
      'prompt': query,  // Adjust this key if needed (depends on Ollama API docs)
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // If the response is successful, return the response
        final data = json.decode(response.body);
        return data['response'] ?? 'No response from server';  // Adjust based on API response structure
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Failed to connect: $e';
    }
  }
}
