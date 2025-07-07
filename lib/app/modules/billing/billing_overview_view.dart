import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BillingOverviewView extends StatelessWidget {
  const BillingOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Billing",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            
          ),
        ),
        elevation: 1,
        backgroundColor: theme.appBarTheme.backgroundColor,
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
            iconColor: colorScheme.tertiary ?? colorScheme.primary,
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
    final iconBackground = theme.colorScheme.surfaceVariant.withOpacity(0.5);

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
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
