import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel(
    super.dateTime,
    super.passage,
    super.report,
    super.speechAnalysisMetrics,
  );
}
