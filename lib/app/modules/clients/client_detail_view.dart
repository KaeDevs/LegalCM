import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/client_model.dart';

class ClientDetailView extends StatelessWidget {
  final ClientModel client;

  const ClientDetailView({super.key, required this.client});

  void _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch phone call');
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                style:  TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.inversePrimary,),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              client.name,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              client.email,
              style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).colorScheme.primary,),
            ),
            const SizedBox(height: 8),
            Text(
              client.contactNumber,
              style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).colorScheme.primary,),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call, color: Theme.of(context).colorScheme.inversePrimary,),
                  label: const Text("Call"),
                  onPressed: () => _makeCall(client.contactNumber),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.email,  color: Theme.of(context).colorScheme.inversePrimary,),
                  label: const Text("Email"),
                  onPressed: () => _sendEmail(client.email),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
