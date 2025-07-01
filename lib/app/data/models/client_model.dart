import 'package:hive/hive.dart';

part 'client_model.g.dart';

@HiveType(typeId: 1)
class ClientModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String contactNumber;

  @HiveField(3)
  String email;

  @HiveField(4)
  String city;

  @HiveField(5)
  String state;

  ClientModel({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.city,
    required this.state,
  });
}
