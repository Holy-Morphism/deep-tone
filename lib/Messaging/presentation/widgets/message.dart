import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/markdown_widget.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              passage,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
          if (speechAnalysisMetricsEntity != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                children: [
                  _buildMetricsRow(
                    "Pitch",
                    speechAnalysisMetricsEntity!.pitch,
                    "Pace",
                    speechAnalysisMetricsEntity!.pace,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricsRow(
                    "Clarity",
                    speechAnalysisMetricsEntity!.clarity,
                    "Volume",
                    speechAnalysisMetricsEntity!.volume,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricsRow(
                    "Pronunciation",
                    speechAnalysisMetricsEntity!.pronunciationAccuracy,
                    "Confidence",
                    speechAnalysisMetricsEntity!.confidence,
                  ),
                  const SizedBox(height: 8),
                  _buildSingleMetric(
                    "Overall",
                    speechAnalysisMetricsEntity!.overallScore,
                  ),
                ],
              ),
            ),
          ],
          if (report != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: MarkdownWidget(
                data: report!,
                shrinkWrap: true,
                config: MarkdownConfig(
                  configs: [
                    PreConfig(
                      textStyle: GoogleFonts.poppins(color: Colors.red),
                    ),
                    PConfig(textStyle: GoogleFonts.poppins()),
                    H1Config(style: GoogleFonts.poppins()),
                    H2Config(style: GoogleFonts.poppins()),
                    H3Config(style: GoogleFonts.poppins()),
                    H4Config(style: GoogleFonts.poppins()),
                    H5Config(style: GoogleFonts.poppins()),
                    H6Config(style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(
    String label1,
    double value1,
    String label2,
    double value2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildSingleMetric(label1, value1)),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleMetric(label2, value2)),
      ],
    );
  }

  Widget _buildSingleMetric(String label, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          value.toStringAsFixed(2),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }
}
