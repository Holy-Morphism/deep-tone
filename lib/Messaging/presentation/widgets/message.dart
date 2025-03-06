import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../../domain/entities/speech_analysis_metrics_entity.dart';

class Message extends StatelessWidget {
  final String passage;
  final SpeechAnalysisMetricsEntity? speechAnalysisMetricsEntity;
  final String? report;
  const Message({
    super.key,
    required this.passage,
    this.speechAnalysisMetricsEntity,
    this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(passage),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Text('🤖')),
              const SizedBox(width: 8.0),
              Text(passage, style: GoogleFonts.poppins()),
            ],
          ),
          if (speechAnalysisMetricsEntity != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pitch: ${speechAnalysisMetricsEntity?.pitch}",
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 8.0),
                Text(
                  "Pace: ${speechAnalysisMetricsEntity?.pace}",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Clarity: ${speechAnalysisMetricsEntity?.clarity}",
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 8.0),
                Text(
                  "Volume: ${speechAnalysisMetricsEntity?.volume}",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pronunciation: ${speechAnalysisMetricsEntity?.pronunciationAccuracy}",
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 8.0),
                Text(
                  "Confidence: ${speechAnalysisMetricsEntity?.confidence}",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            Text(
              "Overall: ${speechAnalysisMetricsEntity?.overallScore}",
              style: GoogleFonts.poppins(),
            ),
          ],

          if (report != null)
            MarkdownWidget(data: report!, shrinkWrap: true)
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
