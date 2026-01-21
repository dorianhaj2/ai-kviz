import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({required this.apiKey});

  /// Generate embedding for text using Gemini
  Future<List<double>> generateEmbedding(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/models/text-embedding-004:embedContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'models/text-embedding-004',
        'content': {
          'parts': [
            {'text': text},
          ],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['embedding']['values']);
    } else {
      throw Exception('Failed to generate embedding: ${response.body}');
    }
  }

  /// Generate quiz questions using Gemini with RAG support
  Future<List<Map<String, dynamic>>> generateQuestions({
    required int count,
    String? topic,
    String difficulty = 'Medium',
    List<String>? existingQuestions, // RAG: Existing questions as context
  }) async {
    final topicPrompt = topic != null ? ' on the topic of: $topic' : '';
    final difficultyPrompt = ' with $difficulty difficulty level';
// Uključujemo postojeća pitanja u prompt
    // RAG: Build context from existing questions
    String contextPrompt = '';
    if (existingQuestions != null && existingQuestions.isNotEmpty) {
      final topicContext = topic != null ? ' about $topic' : '';
      contextPrompt =
          '''
Here are some examples of existing quiz questions$topicContext:
${existingQuestions.map((q) => '- $q').join('\n')}

Please generate questions that are:
- DIFFERENT from these examples (avoid similar topics/concepts)${topic != null ? '\n- Related to $topic' : ''}
- Of $difficulty difficulty level
- Diverse in subject matter${topic != null ? ' within the topic' : ''}
''';
    }

    final prompt =
        '''$contextPrompt

Generate exactly $count multiple-choice quiz questions$topicPrompt$difficultyPrompt.

Difficulty guidelines:
- Easy: Basic knowledge, straightforward facts, common information
- Medium: Requires some knowledge or reasoning, moderate complexity
- Hard: Advanced knowledge, complex reasoning, expert-level information

For each question, provide:
1. A clear, concise question appropriate for the difficulty level
2. Exactly 4 answer options
3. Mark which answer is correct (only one correct answer per question)

Format your response as a JSON array like this:
[
  {
    "question": "What is the capital of France?",
    "answers": {
      "Paris": true,
      "London": false,
      "Berlin": false,
      "Madrid": false
    }
  }
]

Make questions diverse and educational. Ensure answers are clearly right or wrong.''';
    print('Prompt for Gemini:\\n$prompt');
    final response = await http.post(
      /*
        If the model is overloaded, consider switching to:
        gemini-3-flash-preview
        gemini-2.5-flash
        gemini-2.5-flash-lite
        gemini-2.5-pro
        gemini-2.0-flash
        gemini-2.0-flash-lite
      */
      Uri.parse('$baseUrl/models/gemini-3-flash-preview:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        // Proučiti topK topP
        'generationConfig': {'temperature': 0.7, 'topK': 40, 'topP': 0.95},
      }),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];

      // Extract JSON from markdown code blocks if present
      String jsonText = text;
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonMatch != null) {
        jsonText = jsonMatch.group(1)!;
      } else {
        // Try to find JSON array without code blocks
        final arrayMatch = RegExp(r'\[\s*\{[\s\S]*\}\s*\]').firstMatch(text);
        if (arrayMatch != null) {
          jsonText = arrayMatch.group(0)!;
        }
      }
      

      final List<dynamic> questions = jsonDecode(jsonText);
      return questions.map((q) => Map<String, dynamic>.from(q)).toList();
    } else {
      throw Exception('Failed to generate questions: ${response.body}');
    }
  }

  /// Generate quiz questions without using Gemini
  Future<List<Map<String, dynamic>>> generateQuestionsWithoutAI({
    required int count,
    String? topic,
    String difficulty = 'Medium',
    List<String>? existingQuestions, // RAG: Existing questions as context
  }) async {
    
    // This is a placeholder function that simulates question generation without AI.
    // In a real implementation, this could fetch questions from a database or use predefined templates.
    List<Map<String, dynamic>> questions = [];
    for (int i = 0; i < count; i++) {
      questions.add({
        'question': 'Sample question ${i + 1} about ${topic ?? 'various topics'}?',
        'answers': {
          'Option A': false,
          'Option B': true,
          'Option C': false,
          'Option D': false,
        },
      });
    }
    return questions;

  }

  /// Calculate cosine similarity between two embeddings
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same length');
    }

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

  /// Find the most similar question from a list
  Map<String, dynamic> findMostSimilar({
    required List<double> queryEmbedding,
    required List<Map<String, dynamic>> candidates,
  }) {
    double maxSimilarity = -1;
    int maxIndex = -1;

    for (int i = 0; i < candidates.length; i++) {
      final candidateEmbedding = List<double>.from(candidates[i]['embedding']);
      final similarity = cosineSimilarity(queryEmbedding, candidateEmbedding);

      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        maxIndex = i;
      }
    }

    return {
      'index': maxIndex,
      'similarity': maxSimilarity,
      'question': maxIndex >= 0 ? candidates[maxIndex] : null,
    };
  }
}
