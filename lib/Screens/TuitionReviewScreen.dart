import 'package:edunet/Models/ReviewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum FilterOption { mostRecent, topRated, mostHelpful }



class TuitionReviewsScreen extends StatefulWidget {
  const TuitionReviewsScreen({super.key});

  @override
  _TuitionReviewsScreenState createState() => _TuitionReviewsScreenState();
}

class _TuitionReviewsScreenState extends State<TuitionReviewsScreen> {
  FilterOption _currentFilter = FilterOption.mostRecent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Reviews',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF159895),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<FilterOption>(
            icon: const Icon(Icons.filter_list),
            onSelected: (FilterOption result) {
              setState(() {
                _currentFilter = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<FilterOption>>[
              const PopupMenuItem<FilterOption>(
                value: FilterOption.mostRecent,
                child: Text('Most Recent'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.topRated,
                child: Text('Top Rated'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.mostHelpful,
                child: Text('Most Helpful'),
              ),
            ],
          ),
        ],
      ),
      body: ReviewsList(filter: _currentFilter),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add review functionality
        },
        backgroundColor: const Color(0xFF159895),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ReviewsList extends StatelessWidget {
  final FilterOption filter;

  const ReviewsList({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text('Something went wrong',
                  style: TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF159895))));
        }

        List<ReviewModel> reviews = snapshot.data!.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();

        // Apply in-memory sorting for top rated and most helpful
        if (filter == FilterOption.topRated) {
          reviews.sort((a, b) => b.rating.compareTo(a.rating));
        } else if (filter == FilterOption.mostHelpful) {
          reviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        }

        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return AnimatedReviewCard(review: reviews[index]);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    switch (filter) {
      case FilterOption.mostRecent:
        return FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots();
      case FilterOption.topRated:
      case FilterOption.mostHelpful:
        // For these filters, we'll fetch all reviews and sort them in-memory
        return FirebaseFirestore.instance.collection('reviews').snapshots();
    }
  }
}

class AnimatedReviewCard extends StatefulWidget {
  final ReviewModel review;

  const AnimatedReviewCard({super.key, required this.review});

  @override
  _AnimatedReviewCardState createState() => _AnimatedReviewCardState();
}

class _AnimatedReviewCardState extends State<AnimatedReviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markHelpful() {
    FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.review.id)
        .update({
      'helpful': true,
      'helpfulCount': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'avatar_${widget.review.id}',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal[100],
                            child: Text(
                              widget.review.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF159895),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMd().format(widget.review.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.review.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.review.review,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(
                            widget.review.helpful
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            '(${widget.review.helpfulCount})',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: widget.review.helpful ? null : _markHelpful,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
