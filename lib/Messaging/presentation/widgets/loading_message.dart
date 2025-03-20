import 'package:flutter/widgets.dart';

import '../bloc/messaging_bloc.dart';

class LoadingMessage extends StatelessWidget {
  final MessagingState state;
  const LoadingMessage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state is GeneratingPassageState
            ? Text('Generating passage ...')
            : state is AnalysisState
            ? Text('Analysing voice ...')
            : state is GeneratingReportState
            ? Text('Generating Report ...')
            : SizedBox.shrink(),
      ],
    );
  }
}
