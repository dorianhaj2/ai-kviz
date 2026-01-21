import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinecone/pinecone.dart';
import 'gemini_service.dart';
import 'pinecone_service.dart';
import '../firebase_options.dart';

/// Utility to sync existing Firestore questions to Pinecone
/// Run this once to populate Pinecone with your existing questions
Future<void> syncFirestoreToPinecone() async {
  print('Starting Firestore to Pinecone sync...');

  final geminiService = GeminiService(apiKey: geminiApiKey);
  final pineconeService = PineconeService(
    apiKey: pineconeApiKey,
    indexName: pineconeIndexName,
    projectId: pineconeProjectId,
    environment: pineconeEnvironment,
  );

  // Fetch all questions from Firestore
  final snapshot = await FirebaseFirestore.instance
      .collection('Questions')
      .get();

  if (snapshot.docs.isEmpty) {
    print('No questions found in Firestore');
    return;
  }

  print('Found ${snapshot.docs.length} questions in Firestore');
  List<Vector> vectors = [];

  for (var doc in snapshot.docs) {
    try {
      final data = doc.data();
      final question = data['question'] as String;

      print('Processing: $question');

      // Generate embedding
      final embedding = await geminiService.generateEmbedding(question);

      // Prepare vector for Pinecone
      vectors.add(
        Vector(id: doc.id, values: embedding, metadata: {'question': question}),
      );

      print('Generated embedding for: ${question.substring(0, 50)}...');
    } catch (e) {
      print('Error processing question ${doc.id}: $e');
    }
  }

  // Upload to Pinecone in batches
  if (vectors.isNotEmpty) {
    print('\\nUploading ${vectors.length} vectors to Pinecone...');

    // Pinecone recommends batches of 100
    const batchSize = 100;
    for (var i = 0; i < vectors.length; i += batchSize) {
      final end = (i + batchSize < vectors.length)
          ? i + batchSize
          : vectors.length;
      final batch = vectors.sublist(i, end);

      await pineconeService.upsertVectors(vectors: batch);
      print('Uploaded batch ${(i ~/ batchSize) + 1} (${batch.length} vectors)');
    }

    print('\\nSync complete! ${vectors.length} questions now in Pinecone');
  } else {
    print('No vectors to upload');
  }
}
