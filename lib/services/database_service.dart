import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Service for handling Firestore database operations
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger? _logger;

  DatabaseService({Logger? logger}) : _logger = logger;

  /// Creates a new document in the specified collection
  /// 
  /// Returns the document ID of the created document
  Future<String> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger?.d('Creating document in collection: $path');
      final docRef = await _db.collection(path).add(data);
      _logger?.i('Created document with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger?.e('Failed to create document in $path: $e');
      rethrow;
    }
  }

  /// Reads all documents from the specified collection
  /// 
  /// Returns null if the collection is empty or doesn't exist
  Future<QuerySnapshot?> read({required String path}) async {
    try {
      _logger?.d('Reading collection: $path');
      final snapshot = await _db.collection(path).get();
      
      if (snapshot.docs.isNotEmpty) {
        _logger?.i('Found ${snapshot.docs.length} documents in $path');
        return snapshot;
      } else {
        _logger?.w('Collection $path is empty');
        return null;
      }
    } catch (e) {
      _logger?.e('Failed to read collection $path: $e');
      rethrow;
    }
  }

  /// Reads a single document by ID
  Future<DocumentSnapshot?> readDocument({
    required String path,
    required String id,
  }) async {
    try {
      _logger?.d('Reading document: $path/$id');
      final doc = await _db.collection(path).doc(id).get();
      
      if (doc.exists) {
        _logger?.i('Found document: $path/$id');
        return doc;
      } else {
        _logger?.w('Document not found: $path/$id');
        return null;
      }
    } catch (e) {
      _logger?.e('Failed to read document $path/$id: $e');
      rethrow;
    }
  }

  /// Updates an existing document
  Future<void> update({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger?.d('Updating document: $path/$id');
      await _db.collection(path).doc(id).update(data);
      _logger?.i('Successfully updated document: $path/$id');
    } catch (e) {
      _logger?.e('Failed to update document $path/$id: $e');
      rethrow;
    }
  }

  /// Deletes a document
  Future<void> delete({
    required String path,
    required String id,
  }) async {
    try {
      _logger?.d('Deleting document: $path/$id');
      await _db.collection(path).doc(id).delete();
      _logger?.i('Successfully deleted document: $path/$id');
    } catch (e) {
      _logger?.e('Failed to delete document $path/$id: $e');
      rethrow;
    }
  }

  /// Sets a document (creates or overwrites)
  Future<void> set({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      _logger?.d('Setting document: $path/$id');
      await _db.collection(path).doc(id).set(data, SetOptions(merge: merge));
      _logger?.i('Successfully set document: $path/$id');
    } catch (e) {
      _logger?.e('Failed to set document $path/$id: $e');
      rethrow;
    }
  }
}
