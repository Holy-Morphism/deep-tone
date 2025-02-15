import 'package:equatable/equatable.dart';

class ModelMessageEntity extends Equatable {
  final String transcription;
  final String audio;

  const ModelMessageEntity({required this.transcription, required this.audio});

  @override
  List<Object> get props => [transcription, audio];
}
