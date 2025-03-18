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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(child: Text('🤖')),
              const SizedBox(width: 8.0),
              Expanded(child: Text(passage, style: GoogleFonts.poppins())),
            ],
          ),
          if (speechAnalysisMetricsEntity != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Pitch: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.pitch.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Pace: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.pace.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Clarity: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.clarity.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Volume: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.volume.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Pronunciation: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.pronunciationAccuracy.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Confidence: ",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${speechAnalysisMetricsEntity?.confidence.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Overall: ",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "${speechAnalysisMetricsEntity?.overallScore.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
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
