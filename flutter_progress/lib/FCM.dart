import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.messageId}');
      if (message.notification != null) {
        print('Message contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message was opened: ${message.messageId}');
    });

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    if (token != null) {
      await sendTokenToServer(token);
    }
  }

  Future<void> sendTokenToServer(String token) async {
    const String serverUrl = 'http://localhost:8080/register_token';

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      print('Token sent to server successfully');
    } else {
      print('Failed to send token to server');
    }
  }

  Future<void> sendNotification(String title, String body) async {
    const String serverUrl = 'http://localhost:8080/app/notify';

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }
}
