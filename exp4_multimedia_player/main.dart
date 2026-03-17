import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MultimediaApp());

class MultimediaApp extends StatelessWidget {
  const MultimediaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimedia Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const MediaPlayerScreen(),
    );
  }
}

class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({super.key});
  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  static const String _videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
      });
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Multimedia Player'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.red),
            ),
          ),
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_isInitialized)
                  Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(playedColor: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                      onPressed: _isInitialized
                          ? () => _controller.seekTo(
                              _controller.value.position - const Duration(seconds: 10))
                          : null,
                    ),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.red,
                        size: 64,
                      ),
                      onPressed: _isInitialized
                          ? () => _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play()
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                      onPressed: _isInitialized
                          ? () => _controller.seekTo(
                              _controller.value.position + const Duration(seconds: 10))
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.white),
                    Expanded(
                      child: Slider(
                        value: _controller.value.volume,
                        onChanged: (v) => _controller.setVolume(v),
                        activeColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
