import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:legalcm/app/modules/about/view.dart';
import 'package:legalcm/app/utils/tools.dart';
import '../../data/models/case_model.dart';
import '../../data/models/client_model.dart';
import '../../data/models/task_model.dart';
import '../tasks/task_detail_view.dart';
import 'profile_page.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // You can get the controller if you want, or just read directly from Hive here
    // final taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Dashboard',
            style: Tools.oswaldValue(context).copyWith(color: Colors.white),
          ),
          leading: IconButton(
            onPressed: () {
              Get.to(() => const ProfilePage());
            }, 
            icon: Icon(Icons.menu)),
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'About') {
                    Get.to(() => AboutPage());
                  } else {
                    SystemNavigator.pop();
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(value: 'About', child: Text('About')),
                      PopupMenuItem(value: 'Exit', child: Text('Exit')),
                    ])
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              spacing: 16,
              children: <Widget>[
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<CaseModel>('cases').listenable(),
                    builder: (context, Box<CaseModel> caseBox, _) {
                      return DashboardCard(
                        title: 'Cases',
                        value: '${caseBox.length}',
                        icon: Icons.gavel,
                        onTap: () => Get.toNamed('/cases'),
                        color: Colors.indigo,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable:
                        Hive.box<ClientModel>('clients').listenable(),
                    builder: (context, Box<ClientModel> clientBox, _) {
                      return DashboardCard(
                        title: 'Clients',
                        value: '${clientBox.length}',
                        icon: Icons.person,
                        onTap: () => Get.toNamed('/clients'),
                        color: Colors.teal,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 16,
              children: <Widget>[
                Expanded(
                  child: NormalCard(
                    title: 'Calendar',
                    icon: Icons.calendar_month,
                    onTap: () => Get.toNamed('/calendar'),
                    color: const Color.fromARGB(255, 94, 112, 217),
                  ),
                ),
                Expanded(
                  child: NormalCard(
                    title: 'Billing',
                    icon: Icons.currency_rupee_outlined,
                    onTap: () => Get.toNamed('/billing'),
                    color: const Color.fromARGB(255, 94, 112, 217),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              borderOnForeground: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed('/tasks'),
                      child: Text(
                        "Tasks To Do",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'oswald',
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable:
                          Hive.box<TaskModel>('tasks').listenable(),
                      builder: (context, Box<TaskModel> taskBox, _) {
                        final tasks = taskBox.values
                            .where((t) => !t.isCompleted)
                            .toList();

                        if (tasks.isEmpty) {
                          return GestureDetector(
                            onTap: () => Get.toNamed('/tasks'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: theme.colorScheme.primary),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_task,
                                      color: Colors.blueAccent),
                                  const SizedBox(width: 8),
                                  Text(
                                    "No pending tasks — Add Task",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return GestureDetector(
                              onTap: () =>
                                  Get.to(() => TaskDetailView(task: task)),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
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

class NormalCard extends StatelessWidget {
  final String title;
  // final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  NormalCard({
    super.key,
    required this.title,
    // required this.value,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        // weight: 10,
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
                // Flexible(
                //   flex: 1,
                //   child: FittedBox(
                //     fit: BoxFit.scaleDown,
                //     child: Text(
                //       value,
                //       style: Tools.oswaldValue(context).copyWith(
                //         fontSize: size.width * 0.12,
                //         // color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
