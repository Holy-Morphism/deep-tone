import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String passage;
  final double pitch;
  final double pace;
  final double clarity;
  final double volume;
  final double pronunciationAccuracy;
  final double confidence;
  final String transcript;
  final double overallScore;
  final String report;

  const Message({
    super.key,
    required this.passage,
    required this.pitch,
    required this.pace,
    required this.clarity,
    required this.volume,
    required this.pronunciationAccuracy,
    required this.confidence,
    required this.transcript,
    required this.overallScore,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Text('🤖')),
              const SizedBox(width: 8.0),
              Text(passage),
            ],
          ),
        ],
      ),
    );
  }
}
