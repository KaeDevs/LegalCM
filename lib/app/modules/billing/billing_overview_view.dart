import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/font_styles.dart';

class BillingOverviewView extends StatelessWidget {
  const BillingOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Billing",
          style: FontStyles.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary
          ),
          
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withAlpha((0.9 * 255).toInt()),
                colorScheme.secondary.withAlpha((0.9 * 255).toInt()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBillingTile(
            context,
            icon: Icons.timer,
            iconColor: colorScheme.primary,
            title: "Time Entries",
            subtitle: "Track billable hours by case",
            onTap: () => Get.toNamed('/time-entries'),
          ),
          const SizedBox(height: 12),
          _buildBillingTile(
            context,
            icon: Icons.receipt_long,
            iconColor: colorScheme.secondary,
            title: "Expenses",
            subtitle: "Log case-related expenses",
            onTap: () => Get.toNamed('/expense-list'),
          ),
          const SizedBox(height: 12),
          _buildBillingTile(
            context,
            icon: Icons.picture_as_pdf,
            iconColor: colorScheme.tertiary,
            title: "Invoices",
            subtitle: "Generate and view invoices",
            onTap: () => Get.toNamed('/invoice-list'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardColor = theme.cardColor;
    final iconBackground = theme.colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).toInt());

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: cardColor,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: FontStyles.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: FontStyles.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textTheme.bodySmall?.color?.withAlpha((0.7 * 255).toInt()),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
