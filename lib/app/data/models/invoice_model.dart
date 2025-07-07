import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 6)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String caseId;

  @HiveField(2)
  late List<String> timeEntryIds;

  @HiveField(3)
  late List<String> expenseIds;

  @HiveField(4)
  late double totalAmount;

  @HiveField(5)
  late DateTime invoiceDate;

  @HiveField(6)
  late bool isPaid;

@HiveField(7)
String? notes;

  InvoiceModel({
    required this.caseId,
    required this.expenseIds,
    required this.id,
    required this.invoiceDate,
    required this.isPaid,
    required this.timeEntryIds,
    required this.totalAmount,
    this.notes
  });
}
