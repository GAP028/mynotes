import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';

class NotesService {
  final CollectionReference<Map<String, dynamic>> _notes =
      FirebaseFirestore.instance.collection('notes');

  Stream<List<Note>> watchNotes(String userId) {
    return _notes.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(Note.fromDoc).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  Future<void> addNote({
    required String userId,
    required String title,
    required String content,
  }) {
    return _notes.add({
      'userId': userId,
      'title': title.trim(),
      'content': content.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) {
    return _notes.doc(id).update({
      'title': title.trim(),
      'content': content.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) => _notes.doc(id).delete();
}
