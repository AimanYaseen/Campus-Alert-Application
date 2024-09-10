import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For using File

class UpdateAlertSheet extends StatefulWidget {
  final Map<String, dynamic> alertData;

  UpdateAlertSheet({required this.alertData});

  @override
  _UpdateAlertSheetState createState() => _UpdateAlertSheetState();
}

class _UpdateAlertSheetState extends State<UpdateAlertSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _createdByController;
  File? _imageFile; // To store the selected image file
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.alertData['title']);
    _descriptionController = TextEditingController(text: widget.alertData['description']);
    _createdByController = TextEditingController(text: widget.alertData['createdBy']);
    _imageFile = null; // Initially no file is selected
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _updateAlert() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Alerts').doc(widget.alertData['alertId']).update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'createdBy': _createdByController.text,
          // Add imageUrl update if needed
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert updated successfully')));
        Navigator.pop(context, true); // Pass a success flag when closing
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update alert: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, // Allows the bottom sheet to scroll when necessary
      initialChildSize: 0.7, // Starting height of the bottom sheet
      minChildSize: 0.5, // Minimum height of the bottom sheet
      maxChildSize: 0.95, // Maximum height of the bottom sheet
      builder: (context, scrollController) {
        return Container(
          color: Colors.grey[500], // Background color set to grey
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Keyboard overlap handling
            child: SingleChildScrollView(
              controller: scrollController, // Scroll controller for the sheet
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Flexible layout
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Update Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context); // Close the bottom sheet
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Show image picker options: gallery or camera
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.photo),
                                      title: Text('Gallery'),
                                      onTap: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.pop(context); // Close the picker options
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('Camera'),
                                      onTap: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.pop(context); // Close the picker options
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade600),
                              ),
                              child: Center(
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : widget.alertData['imageUrl'] != null
                                        ? Image.network(widget.alertData['imageUrl'], fit: BoxFit.cover)
                                        : Icon(Icons.camera_alt, size: 50, color: Colors.grey.shade600),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.camera_alt, color: Colors.black54), // Camera icon in the rectangular box
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _createdByController,
                        decoration: InputDecoration(labelText: 'Created By'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the creator\'s name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateAlert,
                        child: Text('Update Alert',
                         style: TextStyle(
                          color: Colors.deepPurple
                         ),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
