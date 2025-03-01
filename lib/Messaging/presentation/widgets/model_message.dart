import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../domain/entities/model_message_entity.dart';

class ModelMessage extends StatelessWidget {
  final ModelMessageEntity modelMessageEntity;
  const ModelMessage({super.key, required this.modelMessageEntity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Text('🤖')),
              const SizedBox(width: 8.0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Coach',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('Transcript: ${modelMessageEntity.transcript}'),
                        Text(
                          'Pitch: ${modelMessageEntity.pitch.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Pace: ${modelMessageEntity.pace.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Clarity: ${modelMessageEntity.clarity.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Volume: ${modelMessageEntity.volume.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Pronunciation: ${modelMessageEntity.pronunciationAccuracy.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Confidence: ${modelMessageEntity.confidence.toStringAsFixed(1)}',
                        ),
                        Text(
                          'Overall Score: ${modelMessageEntity.overallScore.toStringAsFixed(1)}',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ),
          MarkdownWidget(data: modelMessageEntity.report, shrinkWrap: true),
        ],
      ),
    );
  }
}
