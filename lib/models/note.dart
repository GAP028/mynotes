import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.updatedAt,
  });

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['updatedAt'];
    return Note(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      content: (data['content'] ?? '') as String,
      userId: (data['userId'] ?? '') as String,
      updatedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
