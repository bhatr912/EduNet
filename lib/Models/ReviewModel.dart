import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userName;
  final DateTime timestamp;
  final double rating;
  final String review;
  final bool helpful;
  final int helpfulCount;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.timestamp,
    required this.rating,
    required this.review,
    required this.helpful,
    required this.helpfulCount,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
      helpful: data['helpful'] ?? false,
      helpfulCount: data['helpfulCount'] ?? 0,
    );
  }
}