import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'alert.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('Message clicked!');
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AlertScreen()));
    }
  }

  @override
  void initState() {
    super.initState();

    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADPC69 - ProtecApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/protection_civile_logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Bienvenue sur ProtecApp',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900]),
            ),
          ],
        ),
      ),
    );
  }
}
