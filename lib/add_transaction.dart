import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dashboard.dart';
import 'database_helper.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController totalPaidAmountController = TextEditingController();
  TextEditingController partiallyPaidAmountController = TextEditingController();

  String selectedType = 'income'; // Default type
  late DatabaseHelper _databaseHelper;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveTransaction() async {
    try {
      await _databaseHelper.insertTransaction(
        customerNameController.text,
        mobileNumberController.text,
        serviceController.text,
        double.parse(totalPaidAmountController.text),
        double.parse(partiallyPaidAmountController.text),
        selectedType,
        _selectedImage?.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaction saved successfully.'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print('Error saving transaction: $e');
      _showValidationError('Error saving transaction. Please try again.');
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: customerNameController,
              decoration: const InputDecoration(labelText: "Customer's Name"),
            ),
            TextField(
              controller: mobileNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Customer's Mobile Number"),
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: serviceController,
              decoration: const InputDecoration(labelText: 'Service'),
            ),
            TextField(
              controller: totalPaidAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Paid Amount'),
            ),
            TextField(
              controller: partiallyPaidAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Partially Paid Amount'),
            ),
            const SizedBox(height: 16.0),

            DropdownButtonFormField(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value.toString();
                });
              },
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
              ],
              decoration: const InputDecoration(labelText: 'Transaction Type'),
            ),

            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Photo'),
              ),
            ),
            const SizedBox(width: 16.0),
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Container(),

      
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                       Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DashboardPage()),
                          );
                  if (customerNameController.text.isEmpty || totalPaidAmountController.text.isEmpty) {
                    _showValidationError('Customer name and total paid amount are required.');
                    return;
                  }
            
                  await _saveTransaction();
            
                      
                },
                child: const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
