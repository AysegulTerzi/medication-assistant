import 'package:flutter/material.dart';

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
  TextEditingController howToUseController = TextEditingController();
  TextEditingController whenToUseController = TextEditingController();

  String selectedHowToUse = '';
  String selectedWhenToUse = '';

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
        return Card(
          color: Colors.grey[200],
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
      RadioListTile(
        title: Text('Full'),
        value: 'Full',
        groupValue: selectedHowToUse,
        onChanged: (value) {
          setState(() {
            selectedHowToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text('Hungry'),
        value: 'Hungry',
        groupValue: selectedHowToUse,
        onChanged: (value) {
          setState(() {
            selectedHowToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text("Doesn't Matter"),
        value: "Doesn't Matter",
        groupValue: selectedHowToUse,
        onChanged: (value) {
          setState(() {
            selectedHowToUse = value.toString();
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
      RadioListTile(
        title: Text('Morning'),
        value: 'Morning',
        groupValue: selectedWhenToUse,
        onChanged: (value) {
          setState(() {
            selectedWhenToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text('Afternoon'),
        value: 'Afternoon',
        groupValue: selectedWhenToUse,
        onChanged: (value) {
          setState(() {
            selectedWhenToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text('Evening'),
        value: 'Evening',
        groupValue: selectedWhenToUse,
        onChanged: (value) {
          setState(() {
            selectedWhenToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text('Night'),
        value: 'Night',
        groupValue: selectedWhenToUse,
        onChanged: (value) {
          setState(() {
            selectedWhenToUse = value.toString();
          });
        },
      ),
      RadioListTile(
        title: Text("Doesn't Matter"),
        value: "Doesn't Matter",
        groupValue: selectedWhenToUse,
        onChanged: (value) {
          setState(() {
            selectedWhenToUse = value.toString();
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
    });
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
}
