import 'package:hive/hive.dart';

part 'case_model.g.dart'; // Generated adapter file

@HiveType(typeId: 0)
class CaseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String clientName;

  @HiveField(3)
  String court;

  @HiveField(4)
  String courtNo;

  @HiveField(5)
  String status;

  @HiveField(6)
  DateTime nextHearing;

  @HiveField(7)
  String notes;

  @HiveField(8)
  String? clientId;

  @HiveField(9)
  String? petitioner;

  @HiveField(10)
  String? petitionerAdv;

  @HiveField(11)
  String? respondent;

  @HiveField(12)
  String? respondentAdv;

  @HiveField(13)
  List<String>? attachedFiles;

  CaseModel({
    required this.id,
    required this.title,
    required this.clientName,
    required this.court,
    required this.courtNo,
    required this.status,
    required this.nextHearing,
    required this.notes, 
    this.clientId,
    this.petitioner,
    this.petitionerAdv,
    this.respondent,
    this.respondentAdv,
    this.attachedFiles
  });
}
