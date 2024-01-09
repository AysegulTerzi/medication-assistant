import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

enum MedicineType {
  Pill,
  Injection,
  Liquid,
  Drop,
  Powder,
}

enum MedicineFrequency {
  Daily,
  EveryOtherDay,
  EveryThreeDays,
}

enum MedicineHowOften {
  Once,
  Twice,
  Thrice,
}

enum MealTime {
  BeforeMeal,
  AfterMeal,
  Anytime,
}

class Medicine {
  String name = '';
  MedicineType type = MedicineType.Pill;
  MedicineFrequency frequency = MedicineFrequency.Daily;
  MedicineHowOften howOften = MedicineHowOften.Once;
  MealTime mealTime = MealTime.Anytime;
  DateTime startDate = DateTime.now();

  Medicine({
    required this.name,
    required this.type,
    required this.frequency,
    required this.howOften,
    required this.mealTime,
    required this.startDate,
  });

  // JSON Serialization
  Map<String, dynamic> toJson() {
    // Sıfırlanmış DateTime nesnesi oluştur
    DateTime zeroedDateTime =
        DateTime(startDate.year, startDate.month, startDate.day);

    return {
      'name': name,
      'type': type.index,
      'frequency': frequency.index,
      'howOften': howOften.index,
      'mealTime': mealTime.index,
      'startDate': DateFormat('yyyy-MM-dd').format(zeroedDateTime),
    };
  }

    // JSON Deserialization
    factory Medicine.fromJson(Map<String, dynamic> json) {
      return Medicine(
        name: json['name'] ?? '',
        type: MedicineType.values[json['type']] ?? MedicineType.Pill,
        frequency: MedicineFrequency.values[json['frequency']] ??
            MedicineFrequency.Daily,
        howOften:
            MedicineHowOften.values[json['howOften']] ?? MedicineHowOften.Once,
        mealTime: MealTime.values[json['mealTime']] ?? MealTime.Anytime,
        startDate:
            DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      );
    }
  }

class MyMedicinesPage extends StatefulWidget {
  @override
  _MyMedicinesPageState createState() => _MyMedicinesPageState();
}

class _MyMedicinesPageState extends State<MyMedicinesPage> {
  List<Medicine> medicines = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Medicines'),
      ),
      body: _buildMedicinesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMedicineDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Card(
            color: Colors.grey[200],
            child: ListTile(
              onTap: () {
                _showMedicineDetails(medicines[index]);
              },
              title: Text(medicines[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Type: ${medicines[index].type.toString().split('.').last}'),
                  Text(
                      'Frequency: ${medicines[index].frequency.toString().split('.').last}'),
                  Text(
                      'How Often: ${medicines[index].howOften.toString().split('.').last}'),
                  Text(
                      'Meal Time: ${medicines[index].mealTime.toString().split('.').last}'),
                  Text('Start Date: ${medicines[index].startDate.toLocal()}'),
                ],
              ),
            ),
          ),
          secondaryActions: [
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                _deleteMedicine(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicineDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailsPage(
          onDetailsSubmitted: (newMedicine) {
            _addMedicine(newMedicine);
          },
        ),
      ),
    );
  }

  void _addMedicine(Medicine newMedicine) {
    setState(() {
      medicines.add(newMedicine);
    });

    // SharedPreferences ile ilaçları kaydetme
    _saveMedicines();
  }

  void _showMedicineDetails(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Medicine Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${medicine.name}'),
              Text('Type: ${medicine.type.toString().split('.').last}'),
              Text(
                  'Frequency: ${medicine.frequency.toString().split('.').last}'),
              Text(
                  'How Often: ${medicine.howOften.toString().split('.').last}'),
              Text(
                  'Meal Time: ${medicine.mealTime.toString().split('.').last}'),
              Text('Start Date: ${medicine.startDate.toLocal()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // SharedPreferences'ten ilaçları yükleme
  void _loadMedicines() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? medicineStrings = prefs.getStringList('medicinesKey');
    if (medicineStrings != null) {
      setState(() {
        medicines = medicineStrings
            .map((jsonString) => Medicine.fromJson(json.decode(jsonString)))
            .toList();
      });
    }
  }

  // SharedPreferences'e ilaçları kaydetme
  void _saveMedicines() {
    List<String> medicineStrings =
        medicines.map((medicine) => json.encode(medicine.toJson())).toList();
    prefs.setStringList('medicinesKey', medicineStrings);
  }

  // İlaç silme işlemi
  void _deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });

    // SharedPreferences ile güncel ilaçları kaydetme
    _saveMedicines();
  }
}

class MedicineDetailsPage extends StatefulWidget {
  final Function(Medicine) onDetailsSubmitted;

  MedicineDetailsPage({required this.onDetailsSubmitted});

  @override
  _MedicineDetailsPageState createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  late String medicineName;
  late MedicineType selectedType;
  late MedicineFrequency selectedFrequency;
  late MedicineHowOften selectedHowOften;
  late MealTime selectedMealTime;
  late DateTime selectedStartDate;

  @override
  void initState() {
    super.initState();
    medicineName = '';
    selectedType = MedicineType.Pill;
    selectedFrequency = MedicineFrequency.Daily;
    selectedHowOften = MedicineHowOften.Once;
    selectedMealTime = MealTime.Anytime;
    selectedStartDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  medicineName = value;
                });
              },
              decoration: InputDecoration(labelText: 'Medicine Name'),
            ),
            DropdownButtonFormField<MedicineType>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: MedicineType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Medicine Type'),
            ),
            DropdownButtonFormField<MedicineFrequency>(
              value: selectedFrequency,
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value!;
                });
              },
              items: MedicineFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Medicine Frequency'),
            ),
            DropdownButtonFormField<MedicineHowOften>(
              value: selectedHowOften,
              onChanged: (value) {
                setState(() {
                  selectedHowOften = value!;
                });
              },
              items: MedicineHowOften.values.map((howOften) {
                return DropdownMenuItem(
                  value: howOften,
                  child: Text(howOften.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'How Often'),
            ),
            DropdownButtonFormField<MealTime>(
              value: selectedMealTime,
              onChanged: (value) {
                setState(() {
                  selectedMealTime = value!;
                });
              },
              items: MealTime.values.map((mealTime) {
                return DropdownMenuItem(
                  value: mealTime,
                  child: Text(mealTime.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Meal Time'),
            ),
            Row(
              children: [
                Text('Start Date: '),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedStartDate) {
                      setState(() {
                        selectedStartDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    '${selectedStartDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final newMedicine = Medicine(
                  name: medicineName,
                  type: selectedType,
                  frequency: selectedFrequency,
                  howOften: selectedHowOften,
                  mealTime: selectedMealTime,
                  startDate: selectedStartDate,
                );
                widget.onDetailsSubmitted(newMedicine);
                Navigator.pop(context);
              },
              child: Text('Add Medicine'),
            ),
          ],
        ),
      ),
    );
  }
}