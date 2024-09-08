import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Subjects App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}

// Models
class ClassModel {
  final String id;
  final String name;
  final List<SubjectModel> subjects;

  ClassModel({required this.id, required this.name, required this.subjects});

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'],
      subjects: [],
    );
  }
}

class SubjectModel {
  final String id;
  final String name;
  final String description;

  SubjectModel({required this.id, required this.name, required this.description});

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}

// Firestore Service
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ClassModel>> getClasses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('classes').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ClassModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  Future<List<SubjectModel>> getSubjects(String classId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('subjects')
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return SubjectModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }
}

// Screens
class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
        elevation: 0,
      ),
      body: FutureBuilder<List<ClassModel>>(
        future: _firestoreService.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No classes found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ClassModel classModel = snapshot.data![index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(classModel.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Tap to view subjects'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailScreen(classModel: classModel),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClassDetailScreen extends StatelessWidget {
  final ClassModel classModel;
  final FirestoreService _firestoreService = FirestoreService();

  ClassDetailScreen({required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.name),
        elevation: 0,
      ),
      body: FutureBuilder<List<SubjectModel>>(
        future: _firestoreService.getSubjects(classModel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No subjects found'));
          }
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              SubjectModel subject = snapshot.data![index];
              return SubjectGridItem(subject: subject);
            },
          );
        },
      ),
    );
  }
}

// Widgets
class SubjectGridItem extends StatelessWidget {
  final SubjectModel subject;

  SubjectGridItem({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Implement subject detail view
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${subject.name}')),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 48, color: Theme.of(context).primaryColor),
              SizedBox(height: 16),
              Text(
                subject.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                subject.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Subjects App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

 */