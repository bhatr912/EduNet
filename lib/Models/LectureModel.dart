import 'package:cloud_firestore/cloud_firestore.dart';

class LectureModel {
  final String id;
  final String name;
  final String teacherName;
  final String batchName;
  final String? imageUrl;
  final String? videoUrl; // New field for video URL

  LectureModel({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.batchName,
    required this.imageUrl,
    required this.videoUrl, // Added to constructor
  });

  factory LectureModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LectureModel(
      id: doc.id,
      name: data['name'] ?? '',
      teacherName: data['teacherName'] ?? '',
      batchName: data['batchName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '', // Added to factory method
    );
  }
}
