import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:legalcm/app/utils/tools.dart';
import '../../data/models/case_model.dart';
import '../../data/models/client_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    final caseBox = Hive.isBoxOpen('cases') ? Hive.box<CaseModel>('cases') : null;
    final clientBox = Hive.isBoxOpen('clients') ? Hive.box<ClientModel>('clients') : null;

    
    

    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text('Dashboard', style: Tools.oswaldValue(context).copyWith(color: Colors.white),), ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: ValueListenableBuilder(
              valueListenable: Hive.box<CaseModel>('cases').listenable(),
              builder: (context, Box<CaseModel> caseBox, _) {
                
                return DashboardCard(
                      title: 'Cases',
                      value: '${caseBox.length}',
                      // icon: Icons.folder,
                      icon: Icons.gavel,
                      onTap: () => Get.toNamed('/cases'),
                      color: Colors.indigo,
                    );}
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ValueListenableBuilder(
                                valueListenable: Hive.box<ClientModel>('clients').listenable(),
                                builder: (context, Box<ClientModel> clientBox, _) {
                  return DashboardCard(
                      title: 'Clients',
                      value: '${clientBox.length}',
                      icon: Icons.person,
                      onTap: () => Get.toNamed('/clients'),
                      color: Colors.teal,
                    );}
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('View Calendar'),
              onPressed: () => Get.toNamed('/calendar'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: size.width * 0.12,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Tools.oswaldValue(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: Tools.oswaldValue(context).copyWith(
                        fontSize: size.width * 0.12,
                        // color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
