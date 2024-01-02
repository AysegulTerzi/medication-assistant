import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Medicine {
  String name = '';
  DateTime startDate = DateTime.now();
  DateTime? estimatedEndDate;
  int usesPerDay = 1;
  String howToUse = '';
  String whenToUse = '';

  Medicine({
    required this.name,
    required this.startDate,
    this.estimatedEndDate,
    required this.usesPerDay,
    required this.howToUse,
    required this.whenToUse,
  });
}

class MyMedicinesPage extends StatefulWidget {
  @override
  _MyMedicinesPageState createState() => _MyMedicinesPageState();
}

class _MyMedicinesPageState extends State<MyMedicinesPage> {
  List<Medicine> medicines = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController estimatedEndDateController = TextEditingController();
  TextEditingController usesPerDayController = TextEditingController();

  String selectedHowToUse = '';
  String selectedWhenToUse = '';

  Medicine? selectedMedicine;

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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildMedicinesList(),
      ),
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
        return Card(
          color: Color.fromARGB(255, 102, 222, 243),
          child: ListTile(
            onTap: () {
              _showMedicineDetails(medicines[index]);
            },
            title: Text(medicines[index].name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Date: ${medicines[index].startDate.toLocal()}'),
                Text('How to Use: ${medicines[index].howToUse}'),
                Text('When to Use: ${medicines[index].whenToUse}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteMedicine(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                ),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(labelText: 'Start Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null && pickedDate != DateTime.now()) {
                      setState(() {
                        startDateController.text = pickedDate.toString();
                      });
                    }
                  },
                ),
                TextField(
                  controller: estimatedEndDateController,
                  decoration: InputDecoration(labelText: 'Estimated End Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null && pickedDate != DateTime.now()) {
                      setState(() {
                        estimatedEndDateController.text = pickedDate.toString();
                      });
                    }
                  },
                ),
                TextField(
                  controller: usesPerDayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Uses Per Day'),
                ),
                ListTile(
                  title: Text('How to Use'),
                  subtitle: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Full'),
                        value: selectedHowToUse == 'Full',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedHowToUse = value! ? 'Full' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Hungry'),
                        value: selectedHowToUse == 'Hungry',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedHowToUse = value! ? 'Hungry' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text("Doesn't Matter"),
                        value: selectedHowToUse == "Doesn't Matter",
                        onChanged: (bool? value) {
                          setState(() {
                            selectedHowToUse = value! ? "Doesn't Matter" : '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('When to Use'),
                  subtitle: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Morning'),
                        value: selectedWhenToUse == 'Morning',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedWhenToUse = value! ? 'Morning' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Afternoon'),
                        value: selectedWhenToUse == 'Afternoon',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedWhenToUse = value! ? 'Afternoon' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Evening'),
                        value: selectedWhenToUse == 'Evening',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedWhenToUse = value! ? 'Evening' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Night'),
                        value: selectedWhenToUse == 'Night',
                        onChanged: (bool? value) {
                          setState(() {
                            selectedWhenToUse = value! ? 'Night' : '';
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text("Doesn't Matter"),
                        value: selectedWhenToUse == "Doesn't Matter",
                        onChanged: (bool? value) {
                          setState(() {
                            selectedWhenToUse = value! ? "Doesn't Matter" : '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addMedicine();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addMedicine() {
    Medicine newMedicine = Medicine(
      name: nameController.text,
      startDate: DateTime.parse(startDateController.text),
      estimatedEndDate: estimatedEndDateController.text.isNotEmpty
          ? DateTime.parse(estimatedEndDateController.text)
          : null,
      usesPerDay: int.tryParse(usesPerDayController.text) ?? 1,
      howToUse: selectedHowToUse,
      whenToUse: selectedWhenToUse,
    );

    setState(() {
      medicines.add(newMedicine);
      selectedHowToUse = '';
      selectedWhenToUse = '';
      _clearControllers();
      _saveMedicines();
    });
  }

  void _showMedicineDetails(Medicine medicine) {
    selectedMedicine = medicine;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Medicine Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${medicine.name}'),
              Text('Start Date: ${medicine.startDate.toLocal()}'),
              Text('Estimated End Date: ${medicine.estimatedEndDate?.toLocal() ?? 'Not specified'}'),
              Text('Uses Per Day: ${medicine.usesPerDay}'),
              Text('How to Use: ${medicine.howToUse}'),
              Text('When to Use: ${medicine.whenToUse}'),
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

  void _deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
      _saveMedicines();
    });
  }

  void _clearControllers() {
    nameController.clear();
    startDateController.clear();
    estimatedEndDateController.clear();
    usesPerDayController.clear();
  }

  void _saveMedicines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> medicineList = medicines.map((med) => med.toString()).toList();
    prefs.setStringList('medicines', medicineList);
  }

  void _loadMedicines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? medicineList = prefs.getStringList('medicines');
    if (medicineList != null) {
      List<Medicine> loadedMedicines = medicineList.map((medStr) {
        List<String> medProps = medStr.split(',');
        return Medicine(
          name: medProps[0],
          startDate: DateTime.parse(medProps[1]),
          estimatedEndDate: medProps[2].isEmpty ? null : DateTime.parse(medProps[2]),
          usesPerDay: int.parse(medProps[3]),
          howToUse: medProps[4],
          whenToUse: medProps[5],
        );
      }).toList();

      setState(() {
        medicines = loadedMedicines;
      });
    }
  }
}
