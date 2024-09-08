import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../Models/models.dart';
import 'TuitionCardScreen.dart';
import 'ViewAllTuitionScreen.dart';

class AllTuitionHomeScreen extends StatelessWidget {
  const AllTuitionHomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.teal,
          floating: true,
          title: Text('EduNet', style: GoogleFonts.pacifico(fontSize: 28,color: Colors.white)),
          actions: [
            IconButton(icon: const Icon(Icons.search,color: Colors.white,), onPressed: () {}),
            IconButton(icon: const Icon(Icons.bookmark,color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person,color: Colors.white), onPressed: () {}),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance.collection('Categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                  child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>  const ShimmerTuitionList(),
                  childCount: 3,
                ),
              );
            }

            List<Category> categories = snapshot.data!.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                    CategorySection(category: categories[index]),
                childCount: categories.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double minCrossAxisExtent;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.minCrossAxisExtent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount =
        (width / (minCrossAxisExtent + crossAxisSpacing)).floor();
        return GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          children: children,
        );
      },
    );
  }
}


class ShimmerTuitionList extends StatelessWidget {
  const ShimmerTuitionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
                right: 8, bottom: 8, left: 8),
            child: Container(
              width: 230,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}


class CategorySection extends StatelessWidget {
  final Category category;

  const CategorySection({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold,fontSize: 24),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF159895),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewAllTuitionScreen(category: category),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 370,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tuitions')
                  .where('category', isEqualTo: category.name)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  const ShimmerTuitionList();
                }

                List<Tuition> tuitions = snapshot.data!.docs
                    .map((doc) => Tuition.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tuitions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(right: 8, bottom: 8, left: 8),
                      child: TuitionCard(
                        tuition: tuitions[index],
                        width: 230,
                        height: 350,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
