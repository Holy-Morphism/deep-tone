import 'dart:convert';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.username, required super.email});

  
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'username': username, 'email': email};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
