import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final List<String> courses;

  ClassModel({required this.id, required this.name, required this.courses});

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      name: data['name'] ?? '',
      courses: List<String>.from(data['subjects'] ?? []),
    );
  }
}
