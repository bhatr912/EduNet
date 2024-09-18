import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/UserModel.dart';
import '../Models/CategoryModel.dart';
import '../Models/TuitionModel.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          UserModel userProfile = UserModel.fromFirestore(snapshot.data!);

          return FutureBuilder(
            // Fetch both Category and Tuition data simultaneously
            future: _fetchCategoryAndTuition(
                userProfile.categoryRef, userProfile.tuitionRef),
            builder:
                (context, AsyncSnapshot<Map<String, dynamic>> dataSnapshot) {
              if (dataSnapshot.hasError) {
                return const Center(
                    child: Text('Error loading profile details'));
              }

              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Extract fetched data
              String categoryName = dataSnapshot.data?['categoryName'] ?? 'N/A';
              String tuitionName = dataSnapshot.data?['tuitionName'] ?? 'N/A';

              // Fetch favorite tuitions' names
              return FutureBuilder<String>(
                future: _buildFavoriteTuitions(userProfile.favoriteTuitions),
                builder: (context, favSnapshot) {
                  if (favSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileImage(userProfile.imageUrl),
                        const SizedBox(height: 16),
                        Text(
                          userProfile.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard('Category', categoryName),
                        _buildInfoCard('Your Tuition', tuitionName),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Fetches Category and Tuition data based on their DocumentReferences
  Future<Map<String, dynamic>> _fetchCategoryAndTuition(
      DocumentReference categoryRef, DocumentReference tuitionRef) async {
    // Fetch both documents in parallel
    var results = await Future.wait([
      categoryRef.get(),
      tuitionRef.get(),
    ]);

    DocumentSnapshot categorySnap = results[0];
    DocumentSnapshot tuitionSnap = results[1];

    String categoryName = categorySnap.exists
        ? CategoryModel.fromFirestore(categorySnap).name
        : 'N/A';
    String tuitionName = tuitionSnap.exists
        ? TuitionModel.fromFirestore(tuitionSnap).name
        : 'N/A';

    return {
      'categoryName': categoryName,
      'tuitionName': tuitionName,
    };
  }

  /// Builds the favorite tuitions' names as a comma-separated string
  Future<String> _buildFavoriteTuitions(
      Map<String, bool> favoriteTuitions) async {
    if (favoriteTuitions.isEmpty) {
      return 'No favorites added';
    }

    // Extract the tuition IDs where the value is true
    List<String> favoriteIds = favoriteTuitions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (favoriteIds.isEmpty) {
      return 'No favorites added';
    }

    // Fetch all favorite tuitions in parallel
    List<Future<DocumentSnapshot>> futures = favoriteIds.map((id) {
      return FirebaseFirestore.instance.collection('Tuitions').doc(id).get();
    }).toList();

    List<DocumentSnapshot> snapshots = await Future.wait(futures);

    // Extract tuition names
    List<String> tuitionNames = snapshots
        .where((snap) => snap.exists)
        .map((snap) => snap['name'] as String? ?? 'Unnamed Tuition')
        .toList();

    return tuitionNames.join(', ');
  }

  Widget _buildProfileImage(String? imageUrl) {
    return CircleAvatar(
      radius: 60,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : null,
      backgroundColor: Colors.teal,
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(Icons.person, size: 60, color: Colors.white)
          : null,
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
