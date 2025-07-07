import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 5)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String caseId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? receiptUrl;

  ExpenseModel({
    required this.id,
    required this.caseId,
    required this.date,
    required this.title,
    required this.amount,
    this.notes,
    this.receiptUrl,
  });
}
