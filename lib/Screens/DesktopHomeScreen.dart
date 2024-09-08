/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const EduNetApp());
}

class EduNetApp extends StatelessWidget {
  const EduNetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobileBody: MobileHomeScreen(),
        desktopBody: DesktopHomeBody(),
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    required this.desktopBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('EduNet', style: GoogleFonts.pacifico(fontSize: 24)),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.bookmark), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
        const SliverToBoxAdapter(child: CategoryList()),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) =>
                CategorySection(category: Categories.values[index]),
            childCount: Categories.values.length,
          ),
        ),
      ],
    );
  }
}


class DesktopHomeBody extends StatefulWidget {
  const DesktopHomeBody({Key? key}) : super(key: key);

  @override
  _DesktopHomeBodyState createState() => _DesktopHomeBodyState();
}

class _DesktopHomeBodyState extends State<DesktopHomeBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: Categories.values
              .map((category) => NavigationRailDestination(
                    icon: Icon(category.icon),
                    label: Text(category.name),
                  ))
              .toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title:
                    Text('EduNet', style: GoogleFonts.pacifico(fontSize: 24)),
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.bookmark), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.person), onPressed: () {}),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        CategorySection(category: Categories.values[index]),
                    childCount: Categories.values.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Categories.values.length,
        itemBuilder: (context, index) {
          final category = Categories.values[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              avatar: Icon(category.icon),
              label: Text(category.name),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          );
        },
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final Categories category;

  const CategorySection({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF159895), // Green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 0), // Allow the button to shrink
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllTuitionsPage(category: category),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 370,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: category.tuitionsCount,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, right: 8, bottom: 8, left: 8),
                  child: TuitionCard(
                    category: category,
                    index: index,
                    width: 230,
                    height: 350,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TuitionCard extends StatelessWidget {
  final Categories category;
  final int index;
  final double width;
  final double height;

  const TuitionCard({
    Key? key,
    required this.category,
    required this.index,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              'https://picsum.photos/500/300?random=${category.hashCode + index}',
              height: height * 0.6,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${category.name} Academy',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Srinager',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('3.6', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text('12', style: Theme.of(context).textTheme.bodySmall),
                      const Icon(Icons.person, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TuitionDetailsPage(
                            category: category,
                            index: index,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text(
                      'Explore',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class AllTuitionsPage extends StatelessWidget {
  final Categories category;
  const AllTuitionsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All ${category.name} Tuitions')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the childAspectRatio based on screen width
          final childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 1.1;

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ResponsiveGrid(
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              minCrossAxisExtent: 180,
              children: List.generate(
                category.tuitionsCount,
                    (index) => TuitionCard(
                  category: category,
                  index: index,
                  width: 350,
                  height: 250,
                ),
              ),
            ),
          );
        },
      ),
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

class TuitionDetailsPage extends StatelessWidget {
  final Categories category;
  final int index;

  const TuitionDetailsPage(
      {Key? key, required this.category, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tuition ${index + 1}')),
      body: Center(
          child: Text('Details for ${category.name} Tuition ${index + 1}')),
    );
  }
}

enum Categories {
  all(Icons.category, 20),
  medical(Icons.local_hospital, 15),
  engineering(Icons.engineering, 18),
  upsc(Icons.account_balance, 12),
  arts(Icons.palette, 10),
  science(Icons.science, 14),
  commerce(Icons.attach_money, 16);

  final IconData icon;
  final int tuitionsCount;
  const Categories(this.icon, this.tuitionsCount);
}

 */