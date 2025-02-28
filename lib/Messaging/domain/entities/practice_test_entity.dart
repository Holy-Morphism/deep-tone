// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class PracticeTestEntity extends Equatable {
  final String passage;
  final String id;
  final DateTime dateTime;
  const PracticeTestEntity({
    required this.passage,
    required this.id,
    required this.dateTime,
  });

  @override
  List<Object> get props => [passage, id, dateTime];
}
