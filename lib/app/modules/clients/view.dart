import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/client_model.dart';
import 'add_client_view.dart';
import 'client_detail_view.dart';

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final clientBox = Hive.box<ClientModel>('clients');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '👥 Clients',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: clientBox.listenable(),
        builder: (context, Box<ClientModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No clients added.',
                style: GoogleFonts.poppins(fontSize: 16, color: theme.hintColor),
              ),
            );
          }

          final clients = box.values.toList();

          return ListView.builder(
            
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: clients.length,
            itemBuilder: (_, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => Get.to(() => ClientDetailView(client: client)),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    client.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${client.email}\n${client.contactNumber}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Get.to(() => AddClientView(), arguments: client);
                      } else if (value == 'delete') {
                        await client.delete();
                        Get.snackbar('Deleted', 'Client removed successfully',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed("/add-client"),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Client'),
      ),
    );
  }
}
