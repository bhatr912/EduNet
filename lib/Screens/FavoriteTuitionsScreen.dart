import 'package:edunet/Models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/TuitionModel.dart';
import 'AllTuitionHomeScreen.dart';
import 'TuitionCardScreen.dart';

class FavoriteTuitionsScreen extends StatelessWidget {
  final String userId;

  const FavoriteTuitionsScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tuition'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No favorite tuitions found.'));
          }

          final userData = UserModel.fromFirestore(snapshot.data!);
          final favoriteTuitionIds = userData.favoriteTuitions.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

          if (favoriteTuitionIds.isEmpty) {
            return const Center(child: Text('No tuition found.'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Tuitions')
                .where(FieldPath.documentId, whereIn: favoriteTuitionIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ShimmerTuitionList());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No tuition found.'));
              }

              final tuitions = snapshot.data!.docs
                  .map((doc) => TuitionModel.fromFirestore(doc))
                  .toList();

              return ListView.builder(
                itemCount: tuitions.length,
                itemBuilder: (context, index) {
                  return TuitionCard(
                    tuition: tuitions[index],
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    userId: userId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
