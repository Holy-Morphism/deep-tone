import '../../domain/entities/model_message_entity.dart';

class ModelMessageModel extends ModelMessageEntity {
  const ModelMessageModel({required super.transcription, required super.audio});
  String get audioData => audio;
  String get transcriptionData => transcription;
  factory ModelMessageModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    final audio = message['audio'] as Map<String, dynamic>;
    
    return ModelMessageModel(
      audio: audio['data'] as String,
      transcription: audio['transcript'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': {
          'audio': {
            'data': audio,
            'transcript': transcription,
          }
        }
      };
}