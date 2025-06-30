import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/case_model.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final Box<CaseModel> caseBox;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CaseModel>> _events = {};

  @override
  void initState() {
    super.initState();
    caseBox = Hive.box<CaseModel>('cases');
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    final cases = caseBox.values.toList();
    final Map<DateTime, List<CaseModel>> events = {};

    for (var c in cases) {
      final date = DateTime(c.nextHearing.year, c.nextHearing.month, c.nextHearing.day);
      events.putIfAbsent(date, () => []).add(c);
    }

    setState(() {
      _events = events;
    });
  }

  List<CaseModel> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<CaseModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: caseBox.listenable(),
              builder: (context, Box<CaseModel> box, _) {
                final events = _getEventsForDay(_selectedDay ?? DateTime.now());

                if (events.isEmpty) {
                  return const Center(child: Text('No hearings on this day.'));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (_, index) {
                    final c = events[index];
                    return ListTile(
                      title: Text(c.title),
                      subtitle: Text('Client: ${c.clientName}'),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
