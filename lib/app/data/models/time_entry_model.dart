import 'package:hive/hive.dart';

part 'time_entry_model.g.dart';

@HiveType(typeId: 4)
class TimeEntryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String caseId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String description;

  @HiveField(4)
  double hours;

  @HiveField(5)
  double rate;

  @HiveField(6)
  double get total => hours * rate;

  // ✅ Add this constructor
  TimeEntryModel({
    required this.id,
    required this.caseId,
    required this.date,
    required this.description,
    required this.hours,
    required this.rate,
  });
}
