import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:protec_app/components/answer_buttons.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/utils/date.dart';
import 'package:protec_app/utils/event.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

import '../components/app_bar.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<StatefulWidget> createState() => _AlertScreen();
}

class _AlertScreen extends State<AlertScreen> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  var event;
  bool edit = false;
  bool canCancel = false;

  void fetchEvent() async {
    print('Fetching event...');
    String eventId = widget.eventId;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    http.get(Uri.parse('$apiUrl/event/$eventId'),
        headers: {'Authorization': 'Bearer $token'}).then((response) {
      if (response.statusCode == 200) {
        Map decoded = jsonDecode(response.body);
        final bool hasNotYetAnswered = decoded["selfAvailability"] == 'pending';
        setState(() {
          event = decoded;
          edit = hasNotYetAnswered;
          canCancel = !hasNotYetAnswered;
        });
      } else {
        if (response.statusCode == 401) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Register()));
        }
        print(response.statusCode);
      }
    });
  }

  void cancel() {
    setState(() {
      edit = false;
    });
  }

  void setAvailability(BuildContext context, bool availability) async {
    final body = {
      'availability': availability.toString(),
      'deviceId': await messaging.getToken(),
    };
    print(body);
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token == null && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Register()));
      return;
    }
    http.post(Uri.parse('$apiUrl/event/${widget.eventId}/answer'),
        body: body,
        headers: {'Authorization': 'Bearer $token'}).then((response) {
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Nous avons bien pris en compte votre réponse', toastLength: Toast.LENGTH_LONG);
        fetchEvent();
      } else {
        print(response.statusCode);
        if (response.statusCode == 401) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Register()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      fetchEvent();
      return Scaffold(
        appBar: appBar('Déclenchement'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: appBar('Déclenchement'),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Ceci est un déclenchement',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const Text('Veuillez indiquer votre disponibilité',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
            Text(event['title'] ?? '',
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text(event['location'] ?? '',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
            Text(dateFormat.format(DateTime.parse(event['start'])) ?? '',
                style: const TextStyle(fontSize: 20)),
            Text(dateFormat.format(DateTime.parse(event['end'])) ?? '',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(
              height: 20,
            ),
            Text(event['comment'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(
              height: 40,
            ),
            edit
                ? AnswerButtons(
                    setAvailability: setAvailability,
                    cancel: cancel,
                    canCancel: canCancel)
                : Column(children: [
                    Text(
                        'Je suis ${toReadableAvailability(event["selfAvailability"])}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            edit = true;
                          });
                        },
                        child: const Text('Modifier ?',
                            style: TextStyle(fontSize: 20)))
                  ]),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () => launchUrlString(
                event['eProtecLink'] ?? '',
                mode: LaunchMode.platformDefault,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple[900]),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Voir sur eProtec'),
            ),
          ]),
        ));
  }
}
