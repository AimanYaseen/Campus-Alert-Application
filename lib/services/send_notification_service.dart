// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegealert/services/get_service_key.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  // Method to send notification to a specific token
  static Future<void> sendNotification({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    String serverKey = await GetServerKey().getServerKeyToken();
    print("Notification server key => $serverKey");
    
    String url = "https://fcm.googleapis.com/v1/projects/collegealert-b24ce/messages:send";
    
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };
    
    // Message structure
    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "data": data,
      }
    };
    
    // Send API request
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );
    
    if (response.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print("Failed to send notification!");
    }
  }

  // Method to send notification to all users
  static Future<void> sendNotificationToAll(String title, String body) async {
    // Fetch all users' device tokens from Firestore
    var usersSnapshot = await FirebaseFirestore.instance.collection('Users').get();
    
    for (var doc in usersSnapshot.docs) {
      String? deviceToken = doc['deviceToken'];
      
      // Send notification if token exists
      if (deviceToken != null) {
        await sendNotification(
          token: deviceToken,
          title: title,
          body: body,
          data: {"click_action": "FLUTTER_NOTIFICATION_CLICK"}, // Custom data if needed
        );
      }
    }
  }
}
