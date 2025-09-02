import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  final String? docId; // optional: editing existing food
  final Map<String, dynamic>? initialData; // optional: pre-fill form

  const AddFoodScreen({Key? key, this.docId, this.initialData}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    // If editing, populate fields
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _foodController.text = data['food'] ?? '';
      _typeController.text = data['type'] ?? '';
      _servingSizeController.text = (data['serving']?['size'] ?? '').toString();
      _selectedUnit = data['serving']?['unit'] ?? 'grams';
      _kcalController.text = (data['nutrition']?['kcal'] ?? '').toString();
      _proteinController.text = (data['nutrition']?['protein'] ?? '').toString();
      _carbsController.text = (data['nutrition']?['carbs'] ?? '').toString();
      _fatController.text = (data['nutrition']?['fat'] ?? '').toString();
    }
  }

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
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc('ChrisPersonal')
        .collection('foods');

    if (widget.docId != null) {
      // Update existing doc
      await collection.doc(widget.docId).update(foodData);
    } else {
      // Create new doc
      foodData['createdAt'] = FieldValue.serverTimestamp();
      await collection.add(foodData);
    }

    // Go back to FoodListScreen
    Navigator.pushNamedAndRemoveUntil(context, '/foodList', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.docId != null ? "Edit Food" : "Add Food")),
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
                  child: Text(widget.docId != null ? "Update" : "Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
