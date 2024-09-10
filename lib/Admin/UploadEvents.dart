import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegealert/services/send_notification_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart'; // For date formatting

class UploadEventsPage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to generate the next Event ID
  Future<String> _generateEventId() async {
    try {
      // Get all the event documents sorted by eventId
      QuerySnapshot querySnapshot = await _firestore
          .collection('Events')
          .orderBy('eventId', descending: true)
          .limit(1) // Only get the last event
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the highest event ID (e.g., EVT-05)
        String lastEventId = querySnapshot.docs.first['eventId'];

        // Extract the number part of the last event ID
        int lastEventNumber = int.parse(lastEventId.split('-')[1]);

        // Increment the event number
        int newEventNumber = lastEventNumber + 1;

        // Return the new event ID (e.g., EVT-06)
        return 'EVT-${newEventNumber.toString().padLeft(2, '0')}';
      } else {
        // If no events exist, start with EVT-01
        return 'EVT-01';
      }
    } catch (e) {
      EasyLoading.showError("Error generating Event ID");
      print(e);
      return '';
    }
  }

  // Function to save event to Firestore and send notification
  Future<void> _saveEventToFirestore(BuildContext context, String title, String message) async {
    try {
      // Generate a new eventId
      String eventId = await _generateEventId();

      if (eventId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate Event ID')),
        );
        return;
      }

      // Add event to Firestore with timestamp as a Firestore Timestamp
      await _firestore.collection('Events').doc(eventId).set({
        'eventId': eventId,
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(), // Saves the current time
      });

      print('Event saved to Firestore successfully.');

      // Send notification to all users
      await SendNotificationService.sendNotificationToAll(title, message);

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event posted and notification sent to all users!')),
      );

      // Close the page after a slight delay to allow the SnackBar to be shown
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print('Failed to save event or send notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }

  // Function to format Firestore Timestamp into a readable date
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy').format(date); // Formats to "Month Day, Year"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Events',
          style: TextStyle(color: Colors.purpleAccent),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.purpleAccent),
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
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade200],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  labelText: 'Event Title',
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade200],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  labelText: 'Event Details',
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.purpleAccent,
              ),
              onPressed: () async {
                final title = _titleController.text;
                final message = _messageController.text;

                if (title.isNotEmpty && message.isNotEmpty) {
                  EasyLoading.show(status: "Saving Event...");
                  await _saveEventToFirestore(context, title, message);
                  EasyLoading.dismiss();

                  // Clear the text fields
                  _titleController.clear();
                  _messageController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields.')),
                  );
                }
              },
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
