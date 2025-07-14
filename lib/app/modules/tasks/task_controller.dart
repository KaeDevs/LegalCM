import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../data/models/task_model.dart';
import '../../services/ad_service.dart';

class TaskController extends GetxController {
  var tasks = <TaskModel>[].obs;
  late Box<TaskModel> taskBox;
  final AdService adService = AdService();

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<TaskModel>('tasks');

    // Load tasks initially
    loadTasks();

    // Load banner ad
    adService.loadBannerAd();

    // Listen for any changes in the box and reload tasks automatically
    taskBox.watch().listen((event) {
      loadTasks();
    });
  }

  void loadTasks() {
    final allTasks = taskBox.values.toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    tasks.assignAll(allTasks);
    // print('Loaded ${tasks.length} tasks');
  }

  void addTask(TaskModel task) async {
    await taskBox.add(task);
    // loadTasks(); // not necessary now, watcher will handle reload
  }

  void updateTask(TaskModel task) async {
    await task.save(); // HiveObject has save() method
    // loadTasks(); // watcher will pick this up
  }

  void deleteSelected(List<TaskModel> selected) {
    for (var task in selected) {
      task.delete();
    }
    // loadTasks(); // watcher will pick this up
  }
}
