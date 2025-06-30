import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:legalcm/app/modules/cases/add_cases_view.dart';
import '../../data/models/case_model.dart';


class CaseDetailView extends StatelessWidget {
  final CaseModel caseData;

  const CaseDetailView({super.key, required this.caseData});

  void _deleteCase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Case'),
        content: const Text('Are you sure you want to delete this case?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await caseData.delete();
      Get.back(); // back to list
      Get.snackbar('Deleted', 'Case removed successfully');
    }
  }

  void _editCase() {
    Get.to(() => AddCaseView(existingCase: caseData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${caseData.title}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Client: ${caseData.clientName}'),
            Text('Court: ${caseData.court}'),
            Text('Status: ${caseData.status}'),
            Text('Next Hearing: ${caseData.nextHearing.day}/${caseData.nextHearing.month}/${caseData.nextHearing.year}'),
            const SizedBox(height: 12),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(caseData.notes),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _editCase,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteCase(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
