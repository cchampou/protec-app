import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/alert.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Déclenchement PC',
    description: 'Déclenchement nécessitant une réponse immédiate de votre part',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
  print(await messaging.getToken());
  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADPC69 - ProtecApp',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const Home(),
    );
  }
}
