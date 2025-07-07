import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legalcm/app/utils/tools.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/case_model.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expenses",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        elevation: 1,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<ExpenseModel>('expenses').listenable(),
        builder: (context, Box<ExpenseModel> expenseBox, _) {
          final caseBox = Hive.box<CaseModel>('cases');

          final Map<String, List<ExpenseModel>> grouped = {};
          for (var expense in expenseBox.values) {
            grouped.putIfAbsent(expense.caseId, () => []).add(expense);
          }

          if (grouped.isEmpty) {
            return Center(
              child: Text(
                "No expenses recorded yet.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final caseId = grouped.keys.elementAt(index);
              final expenses = grouped[caseId]!;

              final caseTitle = caseBox.values
                      .firstWhereOrNull((c) => c.id == caseId)
                      ?.title ??
                  "Unknown Case";

              final totalAmount = expenses.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                color: theme.cardColor,
                child: Theme(
                  data: theme.copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      caseTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      "Total: ₹${totalAmount.toStringAsFixed(2)}",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.secondary,
                      ),
                    ),
                    children: expenses.map((expense) {
                      return ListTile(
                        title: Text(
                          expense.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "${expense.date.toLocal().toString().split(" ")[0]}",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "₹${expense.amount.toStringAsFixed(2)}",
                              style: Tools.oswaldValue(context).copyWith(
                                color: colorScheme.inverseSurface,
                                fontSize: textTheme.bodyLarge?.fontSize,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: Text(
                                      "Delete Expense",
                                      style: textTheme.titleMedium,
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete this expense?",
                                      style: textTheme.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: Text("Cancel",
                                            style: textTheme.labelLarge),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: true),
                                        child: Text(
                                          "Delete",
                                          style: textTheme.labelLarge?.copyWith(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await expense.delete();
                                  Get.snackbar("Deleted", "Expense removed");
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-expense'),
        icon: const Icon(Icons.add),
        label: Text(
          "Add Expense",
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
