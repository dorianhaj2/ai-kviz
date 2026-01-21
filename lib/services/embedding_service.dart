// lib/services/embedding_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmbeddingService {
  final String apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  EmbeddingService({required this.apiKey});
  
  Future<List<double>> generateEmbedding(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/models/text-embedding-004:embedContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'models/text-embedding-004',
        'content': {
          'parts': [{'text': text}]
        }
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['embedding']['values']);
    } else {
      throw Exception('Failed to generate embedding: ${response.body}');
    }
  }
  
  // Calculate cosine similarity between embeddings
  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}