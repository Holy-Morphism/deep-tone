import '../../domain/entities/model_message_entity.dart';

class ModelMessageModel extends ModelMessageEntity {
  ModelMessageModel({
    required super.report,
    required super.pitch,
    required super.pace,
    required super.clarity,
    required super.volume,
    required super.pronunciationAccuracy,
    required super.confidence,
  });
  
}
