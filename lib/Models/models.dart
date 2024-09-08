import 'package:cloud_firestore/cloud_firestore.dart';
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}
class Tuition {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int students;
  final String imageUrl;
  final String category;
  final List<String> adUrls;
  final String desc;
  final List<String> phones; // New field for phone numbers
  final List<String> emails; // New field for email addresses

  Tuition({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.students,
    required this.imageUrl,
    required this.category,
    required this.adUrls,
    required this.desc,
    required this.phones,
    required this.emails,
  });

  factory Tuition.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Tuition(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      students: data['studentCount'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://picsum.photos/500/300?random',
      category: data['category'] ?? '',
      adUrls: List<String>.from(data['adUrls'] ?? []),
      desc: data['desc'] ?? '',
      phones: List<String>.from(data['phones'] ?? []), // Convert to List<String>
      emails: List<String>.from(data['emails'] ?? []), // Convert to List<String>
    );
  }
}

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
