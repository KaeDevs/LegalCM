import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalcm/app/modules/cases/add_cases_view.dart';
import '../../data/models/case_model.dart';
import 'package:open_file/open_file.dart';

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
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete')),
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
    Get.off(() => AddCaseView(existingCase: caseData))!.then((result) {
  if (result == 'updated') {
    print("should go back to tab");
    Get.back(); // Now this pops CaseDetailView
  }

});

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Case Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    caseData.title,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.person, 'Client', caseData.clientName),
                _buildDetailRow(Icons.account_balance, 'Court', caseData.court),
                _buildDetailRow(Icons.numbers, 'Court No', caseData.courtNo),
                _buildDetailRow(Icons.info_outline, 'Status', caseData.status),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Next Hearing',
                  '${caseData.nextHearing.day}/${caseData.nextHearing.month}/${caseData.nextHearing.year}',
                ),
                const SizedBox(height: 16),
                Text('Notes', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(caseData.notes.isNotEmpty
                    ? caseData.notes
                    : 'No additional notes.'),
                const SizedBox(height: 20),
                ExpansionTile(
                    title: Text('Parties', style: textTheme.titleMedium),
                    children: [
                      const SizedBox(height: 3),
                      if (caseData.petitioner != null &&
                          caseData.petitioner!.isNotEmpty)
                        _buildDetailRow(
                            Icons.person, 'Petitioner', caseData.petitioner!),
                      if (caseData.petitionerAdv != null &&
                          caseData.petitionerAdv!.isNotEmpty)
                        _buildDetailRow(Icons.gavel, 'Petitioner Adv.',
                            caseData.petitionerAdv!),
                      if (caseData.respondent != null &&
                          caseData.respondent!.isNotEmpty)
                        _buildDetailRow(Icons.person_outline, 'Respondent',
                            caseData.respondent!),
                      if (caseData.respondentAdv != null &&
                          caseData.respondentAdv!.isNotEmpty)
                        _buildDetailRow(Icons.gavel_outlined, 'Respondent Adv.',
                            caseData.respondentAdv!),
                      const SizedBox(height: 3),
                    ]),
                if (caseData.attachedFiles != null &&
                    caseData.attachedFiles!.isNotEmpty)
                  ExpansionTile(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    title: 
                      Text('Attachments:',
                          style: Theme.of(context).textTheme.titleMedium),
                    children: [
                      const SizedBox(height: 8),
                      ...caseData.attachedFiles!.map((path) => ListTile(
                            title: Text(path.split('/').last),
                            onTap: () async {
                              final result = await OpenFile.open(path);
                              if (result.type != ResultType.done) {
                                Get.snackbar("Error", "Could not open file");
                              }
                            },
                          )),
                    ],
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _editCase,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteCase(context),
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      label: const Text('Delete'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
