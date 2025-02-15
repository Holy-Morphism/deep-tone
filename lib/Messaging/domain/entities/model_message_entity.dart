import 'package:equatable/equatable.dart';

class ModelMessageEntity extends Equatable {
  final String message;
  final String recordedAudio;
  final String modelAudio;

  const ModelMessageEntity({
    required this.message,
    required this.recordedAudio,
    required this.modelAudio,
  });

  @override
  List<Object?> get props => [message, recordedAudio, modelAudio];
}