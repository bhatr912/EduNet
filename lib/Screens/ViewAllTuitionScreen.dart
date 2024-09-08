import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/models.dart';
import 'TuitionCardScreen.dart';
final tuitionsProvider = StreamProvider.autoDispose.family<List<Tuition>, String>((ref, category) {
  return FirebaseFirestore.instance
      .collection('Tuitions')
      .where('category', isEqualTo: category)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Tuition.fromFirestore(doc)).toList());
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final filterProvider = StateProvider.autoDispose<String>((ref) => 'all');

class ViewAllTuitionScreen extends ConsumerStatefulWidget {
  final Category category;
  const ViewAllTuitionScreen({Key? key, required this.category}) : super(key: key);

  @override
  _ViewAllTuitionScreenState createState() => _ViewAllTuitionScreenState();
}

class _ViewAllTuitionScreenState extends ConsumerState<ViewAllTuitionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showAppBar) setState(() => _showAppBar = false);
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showAppBar) setState(() => _showAppBar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tuitions = ref.watch(tuitionsProvider(widget.category.name));
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.teal,
                floating: true,
                pinned: false,
                snap: true,
                title: Text('All ${widget.category.name} Tuitions',style: const TextStyle(color: Colors.white),),
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back,color: Colors.white,),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(_showAppBar ? 60 : 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _showAppBar ? 60 : 4,
                    child: _showAppBar ? _buildSearchBar() : const SizedBox(),
                  ),
                ),
                actions: [
                  _buildFilterButton(),
                ],
              ),
            ];
          },
          body: tuitions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (tuitionList) => _buildTuitionList(tuitionList, searchQuery, filter),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search tuitions...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF159895)),
          suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Color(0xFF159895)),
            onPressed: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF159895), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: const Icon(CupertinoIcons.slider_horizontal_3,color: Colors.white,),
      onSelected: (String result) {
        ref.read(filterProvider.notifier).state = result;
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'all',
          child: Text('All Tuitions'),
        ),
        const PopupMenuItem<String>(
          value: 'top_rated',
          child: Text('Top Rated'),
        ),
      ],
    );
  }

  Widget _buildTuitionList(List<Tuition> tuitions, String searchQuery, String filter) {
    var filteredTuitions = tuitions
        .where((tuition) => tuition.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (filter == 'top_rated') {
      filteredTuitions.sort((a, b) => b.rating.compareTo(a.rating));
      filteredTuitions = filteredTuitions.take(10).toList();
    }

    if (filteredTuitions.isEmpty) {
      return Center(
        child: Text(
          'No match found',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: kToolbarHeight + 8),
      itemCount: filteredTuitions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: TuitionCard(
            tuition: filteredTuitions[index],
            width: double.infinity,
            height: 350,
          ),
        );
      },
    );
  }
}