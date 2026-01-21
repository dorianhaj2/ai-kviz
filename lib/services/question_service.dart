import '../models/question_model.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import '../services/pinecone_service.dart';
import '../core/constants/app_constants.dart';
import 'package:pinecone/pinecone.dart';
import 'package:logger/logger.dart';

/// Service for generating and managing quiz questions
class QuestionService {
  final GeminiService geminiService;
  final DatabaseService databaseService;
  final PineconeService? pineconeService;
  final Logger? logger;

  QuestionService({
    required this.geminiService,
    required this.databaseService,
    this.pineconeService,
    this.logger,
  });

  /// Initializes questions for a quiz on the given topic
  /// Returns a list of questions using RAG (Retrieval-Augmented Generation)
  Future<List<Question>> initializeQuestions(
    String topic, {
    String difficulty = 'Medium',
    int count = 10,
  }) async {
    try {
      logger?.i('Initializing questions for topic: $topic with difficulty: $difficulty');

      // Check if Pinecone is available
      bool usePinecone = pineconeService != null;
      if (usePinecone) {
        try {
          await pineconeService!.describeIndexStats();
          logger?.d('Pinecone connection successful');
        } catch (e) {
          logger?.w('Pinecone unavailable, using local similarity search: $e');
          usePinecone = false;
        }
      }

      // Load existing questions from Firestore
      logger?.d('Loading existing questions from database...');
      final snapshot = await databaseService.read(path: 'Questions');

      final Map<String, Map<String, dynamic>> existingQuestionsMap = {};
      final List<Map<String, dynamic>> existingQuestionsWithEmbeddings = [];

      if (snapshot != null) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          existingQuestionsMap[doc.id] = {
            'id': doc.id,
            'question': data['question'],
            'answers': Map<String, bool>.from(data['answers']),
          };

          if (!usePinecone && data['embedding'] != null) {
            existingQuestionsWithEmbeddings.add({
              'id': doc.id,
              'question': data['question'],
              'answers': Map<String, bool>.from(data['answers']),
              'embedding': List<double>.from(data['embedding']),
            });
          }
        }
      }

      logger?.i('Found ${existingQuestionsMap.length} existing questions');

      // Get relevant questions for the topic using RAG
      final relevantQuestions = await _getTopicRelevantQuestions(
        topic: topic,
        existingQuestionsMap: existingQuestionsMap,
        existingQuestionsWithEmbeddings: existingQuestionsWithEmbeddings,
        usePinecone: usePinecone,
      );

      // Generate new questions from Gemini with RAG context
      logger?.d('Generating $count new questions with RAG...');
      final generatedQuestions = await geminiService.generateQuestions(
        count: count,
        topic: topic,
        difficulty: difficulty,
        existingQuestions: relevantQuestions,
      );

      // Process and deduplicate questions
      final finalQuestions = await _processAndDeduplicateQuestions(
        generatedQuestions: generatedQuestions,
        existingQuestionsMap: existingQuestionsMap,
        existingQuestionsWithEmbeddings: existingQuestionsWithEmbeddings,
        usePinecone: usePinecone,
      );

      logger?.i('Initialized ${finalQuestions.length} questions for quiz');
      return finalQuestions;
    } catch (e) {
      logger?.e('Error initializing questions: $e');
      // Fallback to database questions
      return await _loadFallbackQuestions(topic);
    }
  }

  /// Gets topic-relevant questions using semantic search
  Future<List<String>> _getTopicRelevantQuestions({
    required String topic,
    required Map<String, Map<String, dynamic>> existingQuestionsMap,
    required List<Map<String, dynamic>> existingQuestionsWithEmbeddings,
    required bool usePinecone,
  }) async {
    final List<String> relevantQuestions = [];

    if (existingQuestionsMap.isEmpty) {
      return relevantQuestions;
    }

    logger?.d('Performing topic-based RAG for: $topic');
    final topicEmbedding = await geminiService.generateEmbedding(
      'Quiz questions about $topic',
    );

    if (usePinecone && pineconeService != null) {
      try {
        final similarMatches = await pineconeService!.querySimilar(
          queryVector: topicEmbedding,
          topK: 10,
          includeMetadata: true,
        );

        relevantQuestions.addAll(
          similarMatches
              .where((match) => match.metadata != null)
              .map((match) => match.metadata!['question'] as String),
        );

        logger?.d('Found ${relevantQuestions.length} questions from Pinecone');
      } catch (e) {
        logger?.w('Pinecone search failed: $e');
      }
    } else if (existingQuestionsWithEmbeddings.isNotEmpty) {
      // Local semantic search
      final sortedQuestions = [...existingQuestionsWithEmbeddings];
      sortedQuestions.sort((a, b) {
        final simA = geminiService.cosineSimilarity(
          topicEmbedding,
          List<double>.from(a['embedding']),
        );
        final simB = geminiService.cosineSimilarity(
          topicEmbedding,
          List<double>.from(b['embedding']),
        );
        return simB.compareTo(simA);
      });

      relevantQuestions.addAll(
        sortedQuestions.take(10).map((q) => q['question'] as String),
      );

      logger?.d('Found ${relevantQuestions.length} questions locally');
    }

    // Fallback: random samples if no relevant questions found
    if (relevantQuestions.isEmpty && existingQuestionsMap.isNotEmpty) {
      final samples = existingQuestionsMap.values.toList()..shuffle();
      relevantQuestions.addAll(
        samples.take(10).map((q) => q['question'] as String),
      );
    }

    return relevantQuestions;
  }

  /// Processes generated questions and removes duplicates
  Future<List<Question>> _processAndDeduplicateQuestions({
    required List<Map<String, dynamic>> generatedQuestions,
    required Map<String, Map<String, dynamic>> existingQuestionsMap,
    required List<Map<String, dynamic>> existingQuestionsWithEmbeddings,
    required bool usePinecone,
  }) async {
    final List<Question> finalQuestions = [];

    for (var genQuestion in generatedQuestions) {
      try {
        final questionText = genQuestion['question'] as String;
        logger?.d('Processing: $questionText');

        final questionEmbedding = await geminiService.generateEmbedding(
          questionText,
        );

        bool isDuplicate = false;
        String? existingId;
        double similarity = 0.0;

        // Check for duplicates
        if (usePinecone && pineconeService != null) {
          final similarMatches = await pineconeService!.querySimilar(
            queryVector: questionEmbedding,
            topK: 1,
          );

          if (similarMatches.isNotEmpty) {
            final bestMatch = similarMatches[0];
            similarity = bestMatch.score ?? 0.0;
            existingId = bestMatch.id;
            logger?.d('Most similar question has similarity: ${(similarity * 100.0).toStringAsFixed(2)}%');
          }
        } else if (existingQuestionsWithEmbeddings.isNotEmpty) {
          final result = geminiService.findMostSimilar(
            queryEmbedding: questionEmbedding,
            candidates: existingQuestionsWithEmbeddings,
          );
          similarity = result['similarity'] as double;
          if (result['question'] != null) {
            existingId = result['question']['id'] as String;
          }
          logger?.d('Most similar question has similarity: ${(similarity * 100.0).toStringAsFixed(2)}%');
        }

        if (similarity >= AppConstants.similarityThreshold &&
            existingId != null) {
          // Use existing question
          isDuplicate = true;
          final existingQuestion = existingQuestionsMap[existingId];

          if (existingQuestion != null) {
            logger?.d('Using existing similar question');
            finalQuestions.add(
              Question(
                text: existingQuestion['question'] as String,
                answers: Map<String, bool>.from(existingQuestion['answers']),
              ),
            );
          } else {
            isDuplicate = false;
          }
        }

        if (!isDuplicate) {
          // Save new question
          logger?.d('Question is unique, saving...');
          final docId = await databaseService.create(
            path: 'Questions',
            data: {'question': questionText, 'answers': genQuestion['answers']},
          );

          // Save to Pinecone or Firestore
          if (usePinecone && pineconeService != null) {
            try {
              await pineconeService!.upsertVectors(
                vectors: [
                  Vector(
                    id: docId,
                    values: questionEmbedding,
                    metadata: {'question': questionText},
                  ),
                ],
              );
            } catch (e) {
              logger?.w('Failed to save to Pinecone: $e');
              await databaseService.update(
                path: 'Questions',
                id: docId,
                data: {'embedding': questionEmbedding},
              );
            }
          } else {
            await databaseService.update(
              path: 'Questions',
              id: docId,
              data: {'embedding': questionEmbedding},
            );
          }

          finalQuestions.add(
            Question(
              text: questionText,
              answers: Map<String, bool>.from(genQuestion['answers']),
            ),
          );
        }
      } catch (e) {
        logger?.e('Error processing question: $e');
      }
    }

    return finalQuestions;
  }

  /// Loads fallback questions when generation fails
  Future<List<Question>> _loadFallbackQuestions(String topic) async {
    logger?.w('Loading fallback questions for topic: $topic');

    try {
      final snapshot = await databaseService.read(path: 'Questions');

      if (snapshot == null || snapshot.docs.isEmpty) {
        return [];
      }

      final allQuestions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'question': data['question'],
          'answers': Map<String, bool>.from(data['answers']),
          'embedding': data['embedding'] != null
              ? List<double>.from(data['embedding'])
              : null,
        };
      }).toList();

      // Try to filter by topic using embeddings
      if (allQuestions.any((q) => q['embedding'] != null)) {
        try {
          final topicEmbedding = await geminiService.generateEmbedding(
            'Quiz questions about $topic',
          );

          final questionsWithEmbeddings = allQuestions
              .where((q) => q['embedding'] != null)
              .toList();

          questionsWithEmbeddings.sort((a, b) {
            final simA = geminiService.cosineSimilarity(
              topicEmbedding,
              List<double>.from(a['embedding']),
            );
            final simB = geminiService.cosineSimilarity(
              topicEmbedding,
              List<double>.from(b['embedding']),
            );
            return simB.compareTo(simA);
          });

          return questionsWithEmbeddings
              .take(10)
              .map(
                (q) => Question(
                  text: q['question'] as String,
                  answers: Map<String, bool>.from(q['answers']),
                ),
              )
              .toList();
        } catch (e) {
          logger?.w('Could not filter by topic: $e');
        }
      }

      // Random fallback
      allQuestions.shuffle();
      return allQuestions
          .take(10)
          .map(
            (q) => Question(
              text: q['question'] as String,
              answers: Map<String, bool>.from(q['answers']),
            ),
          )
          .toList();
    } catch (e) {
      logger?.e('Fallback also failed: $e');
      return [];
    }
  }
}
