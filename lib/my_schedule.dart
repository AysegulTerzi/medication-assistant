import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'my_medicines.dart';
import 'dart:convert';  // Eklenen kısım

class MySchedulePage extends StatefulWidget {
  @override
  _MySchedulesPageState createState() => _MySchedulesPageState();
}
class SelectedMedicinesCard extends StatelessWidget {
  final List<Medicine> selectedMedicines;

  SelectedMedicinesCard({required this.selectedMedicines});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: ListTile(
        title: Text('Selected Medicines'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectedMedicines
              .map((medicine) => Text(
                    '${medicine.name}, ${medicine.type.toString().split('.').last}',
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _MySchedulesPageState extends State<MySchedulePage> {
  List<Medicine> medicines = [];
  late Map<DateTime, List<Medicine>> events;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Schedules'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: _buildSelectedMedicinesCard(),
          ),
        ],
      ),
    );
  }

Widget _buildCalendar() {
  return TableCalendar(
    focusedDay: DateTime.now(),
    firstDay: DateTime(2000),
    lastDay: DateTime(2101),
    calendarFormat: CalendarFormat.month,
    headerStyle: HeaderStyle(
      formatButtonTextStyle: TextStyle().copyWith(color: Colors.white),
      formatButtonDecoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    onDaySelected: (selectedDay, focusedDay) {
      setState(() {
        // Update the displayed medicines based on the selected day
        _updateDisplayedMedicines(selectedDay);
      });
    },
  );
}

List<Medicine> _updateDisplayedMedicines(DateTime selectedDay) {
  // Convert selectedDay to midnight (00:00:00)
  DateTime selectedDayMidnight = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

  List<Medicine> selectedDayMedicines = events[selectedDayMidnight] ?? [];

  // Print the selected medicines with a more readable date format
  print('Selected Medicines for ${selectedDay.toLocal()}: $selectedDayMedicines');
  
  // Update the selected medicines
  return selectedDayMedicines;

}

Widget _buildSelectedMedicinesCard() {
  return SelectedMedicinesCard(selectedMedicines: _updateDisplayedMedicines(DateTime.now()));
}



  // Widget _buildSchedulesList() {
  //   return ListView.builder(
  //     itemCount: medicines.length,
  //     itemBuilder: (context, index) {
  //       return Card(
  //         color: Colors.grey[200],
  //         child: ListTile(
  //           title: Text(medicines[index].name),
  //           subtitle: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Type: ${medicines[index].type.toString().split('.').last}'),
  //               Text('Frequency: ${medicines[index].frequency.toString().split('.').last}'),
  //               Text('How Often: ${medicines[index].howOften.toString().split('.').last}'),
  //               Text('Meal Time: ${medicines[index].mealTime.toString().split('.').last}'),
  //               Text('Start Date: ${medicines[index].startDate.toLocal()}'),
  //               Text('End Date: ${medicines[index].endDate.toLocal()}'),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


  void _loadMedicines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? medicineStrings = prefs.getStringList('medicinesKey');
    if (medicineStrings != null) {
      setState(() {
        medicines = medicineStrings
            .map((jsonString) => Medicine.fromJson(json.decode(jsonString)))
            .toList();
        events = _generateEvents(medicines);
      });
    }
  }

  Map<DateTime, List<Medicine>> _generateEvents(List<Medicine> medicines) {
    Map<DateTime, List<Medicine>> events = {};

    for (var medicine in medicines) {
      DateTime startDate = medicine.startDate;
      DateTime endDate = medicine.endDate;

      while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        events[startDate] = events[startDate] ?? [];
        events[startDate]!.add(medicine);

        startDate = startDate.add(Duration(days: 1));
      }
    }

    return events;
  }
}
