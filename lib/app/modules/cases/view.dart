import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/case_model.dart';
import 'case_detail_view.dart';

class CasesView extends StatelessWidget {
  const CasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final caseBox = Hive.box<CaseModel>('cases');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📁 All Cases',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9),
                colorScheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: caseBox.listenable(),
        builder: (context, Box<CaseModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No cases found.',
                style: GoogleFonts.poppins(fontSize: 18, color: theme.hintColor),
              ),
            );
          }

          final cases = box.values.toList().cast<CaseModel>();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return Card(
                elevation: 3,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () => Get.to(() => CaseDetailView(caseData: c)),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge!.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: theme.iconTheme.color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.clientName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium!.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.account_balance, size: 16, color: theme.iconTheme.color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.court,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium!.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(c.status, colorScheme),
                            Row(
                              children: [
                                Icon(Icons.calendar_month, size: 16, color: theme.iconTheme.color),
                                const SizedBox(width: 4),
                                Text(
                                  '${c.nextHearing.day}/${c.nextHearing.month}/${c.nextHearing.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: theme.textTheme.bodySmall!.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-case'),
        icon: const Icon(Icons.add),
        label: const Text('Add Case'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme scheme) {
    Color chipColor;
    switch (status) {
      case 'Closed':
        chipColor = Colors.redAccent;
        break;
      case 'In Progress':
        chipColor = Colors.orange;
        break;
      case 'Pending':
      default:
        chipColor = scheme.primary;
        break;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }
}
