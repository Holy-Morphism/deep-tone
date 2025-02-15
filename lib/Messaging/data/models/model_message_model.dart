import '../../domain/entities/model_message_entity.dart';

class ModelMessageModel extends ModelMessageEntity {
  const ModelMessageModel({
    required super.message,
    required super.recordedAudio,
    required super.modelAudio,
  });

  factory ModelMessageModel.fromJson(
    Map<String, dynamic> json,
    String recordedAudio,
  ) {
    final audio =
        json["choices"][0]['message']['audio'] as Map<String, dynamic>;

    return ModelMessageModel(
      message: audio['transcript'] as String,
      recordedAudio: recordedAudio,
      modelAudio: audio['data'] as String,
    );
  }
}
