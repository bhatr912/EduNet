import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Topper {
  final String name;
  final String? imageUrl;
  final int score;
  final int total;
  final int year;
  final String exam;

  Topper({
    required this.name,
    this.imageUrl,
    required this.score,
    required this.total,
    required this.year,
    required this.exam,
  });

  factory Topper.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Topper(
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      score: data['score'] ?? 0,
      total: data['total'] ?? 100,
      year: data['year'] ?? 0,
      exam: data['exam'] ?? '',
    );
  }
}

class TuitionToppersScreen extends StatefulWidget {
  const TuitionToppersScreen({Key? key}) : super(key: key);

  @override
  _TuitionToppersScreenState createState() => _TuitionToppersScreenState();
}

class _TuitionToppersScreenState extends State<TuitionToppersScreen> {
  int? selectedYear;
  String? selectedExam;
  List<int> availableYears = [];
  List<String> availableExams = [];
  bool isLoading = true;
  bool isYearFilter = true; // To toggle between year and exam filter

  @override
  void initState() {
    super.initState();
    _loadAvailableYearsAndExams();
  }

  Future<void> _loadAvailableYearsAndExams() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot docs =
      await FirebaseFirestore.instance.collection('Tuition_Toppers').get();

      Set<int> years = {};
      Set<String> exams = {};

      for (var doc in docs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        years.add(data['year'] as int);
        exams.add(data['exam'] as String);
      }

      if (mounted) {
        setState(() {
          availableYears = years.toList()
            ..sort((a, b) => b.compareTo(a));
          availableExams = exams.toList()
            ..sort();
          selectedYear = null; // Set to null for "All Years"
          selectedExam = null; // Set to null for "All Exams"
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading years and exams: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Toppers'),
        backgroundColor:const Color(0xFF159895),
        actions: [
          IconButton(
            icon: Icon(isYearFilter ? Icons.calendar_today : Icons.school),
            onPressed: () {
              setState(() {
                isYearFilter = !isYearFilter;
              });
            },
          ),
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<dynamic>(
                value: isYearFilter ? selectedYear : selectedExam,
                items: [
                  DropdownMenuItem<dynamic>(
                    value: null,
                    child: Text(isYearFilter ? 'All Years' : 'All Exams'),
                  ),
                  ...(isYearFilter ? availableYears : availableExams)
                      .map((value) {
                    return DropdownMenuItem<dynamic>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    if (isYearFilter) {
                      selectedYear = value as int?;
                    } else {
                      selectedExam = value as String?;
                    }
                  });
                },
                dropdownColor:const Color(0xFF159895),
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildToppersGrid(),
    );
  }

  Widget _buildToppersGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No toppers found'));
        }

        List<Topper> toppers = snapshot.data!.docs
            .map((doc) => Topper.fromFirestore(doc))
            .toList();
        // Sort toppers by score in descending order
        toppers.sort((a, b) => b.score.compareTo(a.score));

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: toppers.length,
          itemBuilder: (context, index) => _buildTopperCard(toppers[index]),
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('Tuition_Toppers');

    if (selectedYear != null) {
      query = query.where('year', isEqualTo: selectedYear);
    }

    if (selectedExam != null) {
      query = query.where('exam', isEqualTo: selectedExam);
    }

    return query.snapshots();
  }

  Widget _buildTopperCard(Topper topper) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF159895), Color(0xFF159895)],
                    ),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                ),
                Hero(
                  tag: 'topper_${topper.name}',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: topper.imageUrl != null &&
                          topper.imageUrl!.isNotEmpty
                          ? Image.network(
                        topper.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return _buildPersonIcon();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          );
                        },
                      )
                          : _buildPersonIcon(),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Text(
                      '${topper.score}/${topper.total}',
                      style: const TextStyle(
                        color: Color(0xFF159895),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    topper.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18,color: Color(0xFF159895),),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${topper.year} - ${topper.exam}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonIcon() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.teal,
      ),
    );
  }
}
