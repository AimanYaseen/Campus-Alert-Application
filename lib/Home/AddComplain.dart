import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddComplainPage extends StatefulWidget {
  @override
  _AddComplainPageState createState() => _AddComplainPageState();
}

class _AddComplainPageState extends State<AddComplainPage> {
  final TextEditingController _complainController = TextEditingController();
  DateTime? _selectedDate;
  String? compId;

  @override
  void initState() {
    super.initState();
    generateCompId(); // Generate complaint ID when page loads
  }

  // Function to generate a unique CompId
  Future<void> generateCompId() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Complains').get();
    int count = snapshot.size + 1;
    setState(() {
      compId = 'CompId-${count.toString().padLeft(2, '0')}'; // Format CompId-01, CompId-02
    });
  }

  // Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to save complain to Firestore
  Future<void> _saveComplain() async {
    if (_complainController.text.isEmpty || _selectedDate == null) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields'),
      ));
      return;
    }

    // Show loading while saving
    EasyLoading.show(status: 'Submitting...');

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('Complains').doc(compId).set({
        'complain': _complainController.text,
        'date': Timestamp.fromDate(_selectedDate!), // Save date as Timestamp
        'compId': compId,
      });

      // Hide loading
      EasyLoading.dismiss();

      // Show success message
      EasyLoading.showSuccess('Complain added successfully!');

      // Clear form
      _complainController.clear();
      setState(() {
        _selectedDate = null;
      });
    } catch (error) {
      // Hide loading and show error
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to submit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Add Complains',
        style: TextStyle(
          color:Colors.purpleAccent
        ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Colors.deepPurple.shade900,
              Colors.purple.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (compId != null)
              Text(
                'Complaint ID: $compId',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            // Complain Text Field
            TextField(
              controller: _complainController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your complain',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.white.withOpacity(0.1),
                filled: true,
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            // Date Field
            TextButton(
              onPressed: () => _pickDate(context),
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Selected Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: _saveComplain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600, // Background color
              ),
              child: Text('Submit Complain',
                              style: TextStyle(color: Colors.white,fontSize: 16),
),
            ),
          ],
        ),
      ),
    );
  }
}
