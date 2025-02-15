import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String base64Audio;
  final String label;

  const AudioPlayerWidget({
    super.key,
    required this.base64Audio,
    required this.label,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    // Decode base64 to bytes
    final bytes = base64Decode(widget.base64Audio);

    // Get temporary directory to store the audio file
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    // Write bytes to file
    await file.writeAsBytes(bytes);
    _audioFilePath = file.path;

    // Set the audio source
    await _audioPlayer.setFilePath(_audioFilePath!);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // Clean up the temporary file
    if (_audioFilePath != null) {
      File(_audioFilePath!).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.play();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
