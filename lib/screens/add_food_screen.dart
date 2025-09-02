import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();
  final TextEditingController _kcalController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  String _selectedUnit = 'grams';
  final List<String> _units = [
    'grams',
    'ounces',
    'fluid ounces',
    'tbsp',
    'tsp',
    'cup',
    'unit',
    'ml',
    'liter',
  ];

  Future<void> _saveFood() async {
    final foodData = {
      'food': _foodController.text,
      'type': _typeController.text,
      'serving': {
        'size': double.tryParse(_servingSizeController.text) ?? 0,
        'unit': _selectedUnit,
      },
      'nutrition': {
        'kcal': double.tryParse(_kcalController.text) ?? 0,
        'protein': double.tryParse(_proteinController.text) ?? 0,
        'carbs': double.tryParse(_carbsController.text) ?? 0,
        'fat': double.tryParse(_fatController.text) ?? 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc('ChrisPersonal')
        .collection('foods')
        .add(foodData);

    Navigator.pop(context); // close after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Food")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _foodController,
                  decoration: const InputDecoration(labelText: "Food"),
                ),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _servingSizeController,
                        decoration: const InputDecoration(labelText: "Serving Size"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedUnit,
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: _kcalController,
                  decoration: const InputDecoration(labelText: "Calories (kcal)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _proteinController,
                  decoration: const InputDecoration(labelText: "Protein (g)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _carbsController,
                  decoration: const InputDecoration(labelText: "Carbs (g)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _fatController,
                  decoration: const InputDecoration(labelText: "Fat (g)"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveFood,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
