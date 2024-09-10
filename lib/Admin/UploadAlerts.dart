import 'package:collegealert/Admin/AlertDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; 

class UploadAlertsPage extends StatefulWidget {
  @override
  _UploadAlertsPageState createState() => _UploadAlertsPageState();
}

class _UploadAlertsPageState extends State<UploadAlertsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isUploading = false;
  File? _imageFile;

  String _adminUsername = '';
  String _nextAlertId = '';

  @override
  void initState() {
    super.initState();
    _fetchAdminUsername();
    _getNextAlertId();

    // Set the current date as default in the date field
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchAdminUsername() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc('3deiEacRNTRXRjHibsDIKi80Sfn2') 
          .get();

      if (userDoc.exists) {
        setState(() {
          _adminUsername = userDoc['username'];
        });
      }
    } catch (e) {
      print('Error fetching admin username: $e');
    }
  }

  Future<void> _getNextAlertId() async {
    try {
      QuerySnapshot alertSnapshot = await FirebaseFirestore.instance
          .collection('Alerts')
          .orderBy('alertId', descending: true)
          .limit(1)
          .get();

      if (alertSnapshot.docs.isNotEmpty) {
        String lastAlertId = alertSnapshot.docs.first['alertId'];
        int nextIdNum = int.parse(lastAlertId.split('-')[1]) + 1;
        _nextAlertId = 'AL-${nextIdNum.toString().padLeft(5, '0')}';
      } else {
        _nextAlertId = 'AL-00001';
      }
    } catch (e) {
      print('Error getting next Alert ID: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030),  
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); 
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = _nextAlertId; 
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('alert_images/$fileName'); 

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _uploadAlert() async {
  String title = _titleController.text.trim();
  String description = _descriptionController.text.trim();
  String dateText = _dateController.text.trim(); // This is still a string

  if (title.isNotEmpty && description.isNotEmpty && dateText.isNotEmpty) {
    setState(() {
      _isUploading = true;
    });

    String? imageUrl;

    // Upload image to Firebase Storage if selected
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    try {
      // Convert the string date into a DateTime object and then to Timestamp
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateText);
      Timestamp timestamp = Timestamp.fromDate(date);

      await FirebaseFirestore.instance.collection('Alerts').doc(_nextAlertId).set({
        'alertId': _nextAlertId,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'date': timestamp, // Store the date as a Timestamp
        'createdBy': _adminUsername,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Alert uploaded successfully!'),
        backgroundColor: Colors.green,
      ));

      // Navigate to Alert Details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlertDetailsPage(alertId: _nextAlertId), 
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      setState(() {
        _imageFile = null;
      });

      _getNextAlertId(); // Generate next Alert ID
    } catch (e) {
      print('Error uploading alert: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload alert'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please fill all fields'),
      backgroundColor: Colors.red,
    ));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload Alerts for Students',
          style: TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              Colors.deepPurple.shade700,
              Colors.purple.shade500,
              Colors.lightBlueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: TextEditingController(text: _nextAlertId),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Alert ID',
                labelStyle: TextStyle(color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _dateController, 
              readOnly: true,
              onTap: _selectDate, 
              decoration: InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.purpleAccent),
                labelStyle: TextStyle(color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Alert Title',
                labelStyle: TextStyle(color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Alert Description',
                labelStyle: TextStyle(color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),           
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Select Image',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                if (_imageFile != null)
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                _isUploading ? 'Uploading...' : 'Upload Alert',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
