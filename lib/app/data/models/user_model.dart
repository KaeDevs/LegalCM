import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String city;

  @HiveField(4)
  String state;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.state,
  });
} 