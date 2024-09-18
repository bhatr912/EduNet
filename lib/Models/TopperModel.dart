import 'package:cloud_firestore/cloud_firestore.dart';

class TopperModel {
  final String name;
  final String? imageUrl;
  final int score;
  final int total;
  final int year;
  final String exam;

  TopperModel({
    required this.name,
    this.imageUrl,
    required this.score,
    required this.total,
    required this.year,
    required this.exam,
  });

  factory TopperModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TopperModel(
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      score: data['score'] ?? 0,
      total: data['total'] ?? 100,
      year: data['year'] ?? 0,
      exam: data['exam'] ?? '',
    );
  }
}
