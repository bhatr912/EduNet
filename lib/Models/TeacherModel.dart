import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String subject;
  final String qualification;
  final String bio;

  TeacherModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.subject,
    required this.qualification,
    required this.bio,
  });

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      subject: data['subject'] ?? '',
      qualification: data['qualification'] ?? '',
      bio: data['bio'] ?? '',
    );
  }
}
