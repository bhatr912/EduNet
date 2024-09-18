import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int helpCounter;
  final DocumentReference categoryRef;
  final DocumentReference tuitionRef;
  final Map<String, bool> favoriteTuitions;

  UserModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.helpCounter,
    required this.categoryRef,
    required this.tuitionRef,
    required this.favoriteTuitions,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      helpCounter: data['helpCounter'] ?? 0,
      categoryRef: data['categoryRef'] ??
          FirebaseFirestore.instance.collection('Categories').doc(),
      tuitionRef: data['tuitionRef'] ??
          FirebaseFirestore.instance.collection('Tuitions').doc(),
      favoriteTuitions: Map<String, bool>.from(data['favoriteTuitions'] ?? {}),
    );
  }
}
