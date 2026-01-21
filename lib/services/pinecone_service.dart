import 'package:pinecone/pinecone.dart';

class PineconeService {
  final String apiKey;
  final String indexName;
  final String projectId;
  final String environment;
  late final PineconeClient _client;

  PineconeService({
    required this.apiKey,
    required this.indexName,
    required this.projectId,
    required this.environment,
  }) {
    _client = PineconeClient(apiKey: apiKey);
  }

  Future<List<String>> listIndexes() async {
    return await _client.listIndexes();
  }

  /// Upsert (insert/update) vectors to Pinecone
  Future<UpsertResponse> upsertVectors({
    required List<Vector> vectors,
    String? namespace,
  }) async {
    return await _client.upsertVectors(
      indexName: indexName,
      projectId: projectId,
      environment: environment,
      request: UpsertRequest(vectors: vectors, namespace: namespace ?? ''),
    );
  }

  /// Query similar vectors from Pinecone
  Future<List<VectorMatch>> querySimilar({
    required List<double> queryVector,
    required int topK,
    bool includeMetadata = true,
    bool includeValues = false,
    String? namespace,
  }) async {
    final response = await _client.queryVectors(
      indexName: indexName,
      projectId: projectId,
      environment: environment,
      request: QueryRequest(
        vector: queryVector,
        topK: topK,
        includeMetadata: includeMetadata,
        includeValues: includeValues,
        namespace: namespace ?? '',
      ),
    );

    return response.matches;
  }

  /// Fetch vectors by IDs
  Future<Map<String, Vector>> fetchVectors(
    List<String> ids, {
    String? namespace,
  }) async {
    final response = await _client.fetchVectors(
      indexName: indexName,
      projectId: projectId,
      environment: environment,
      ids: ids,
      namespace: namespace ?? '',
    );

    return response.vectors;
  }

  /// Delete vectors by IDs
  Future<void> deleteVectors(List<String> ids, {String? namespace}) async {
    await _client.deleteVectors(
      indexName: indexName,
      projectId: projectId,
      environment: environment,
      request: DeleteRequest(ids: ids, namespace: namespace ?? ''),
    );
  }

  /// Get index statistics
  Future<IndexStats> describeIndexStats() async {
    return await _client.describeIndexStats(
      indexName: indexName,
      projectId: projectId,
      environment: environment,
    );
  }
}
