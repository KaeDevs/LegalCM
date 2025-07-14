import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../data/models/case_model.dart';
import '../../data/models/task_model.dart';
import '../../services/ad_service.dart';
import 'controller.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    // Add your calendar UI here, using controller for any state
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: Text('Calendar content goes here'),
      ),
    );
  }
}