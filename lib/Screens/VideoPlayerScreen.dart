
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String lectureTitle;
  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.lectureTitle,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePip: true,
          enablePlayPause: true,
          enableMute: true,
          enableProgressBar: true,
          enableSkips: true,
          enablePlaybackSpeed: true,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lectureTitle),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lectureTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Lecture Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This is where you can add a detailed description of the lecture. "
                        "You can include information about the topics covered, any prerequisites, "
                        "and what students can expect to learn from this video.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement download functionality
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Download for Offline Viewing"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }
}