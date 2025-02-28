import 'package:flutter/material.dart';

import '../../domain/entities/model_message_entity.dart';

class ModelMessage extends StatelessWidget {
  final ModelMessageEntity modelMessageEntity;
  const ModelMessage({super.key, required this.modelMessageEntity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Text('🤖')),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Coach',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4.0),
                Text(modelMessageEntity.report),

                // Padding(
                //   padding: const EdgeInsets.only(top: 8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       AudioPlayerWidget(
                //         base64Audio: modelMessageEntity.recordedAudio,
                //         label: 'Your Recording',
                //       ),
                //       AudioPlayerWidget(
                //         base64Audio: modelMessageEntity.modelAudio,
                //         label: 'AI Response',
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
