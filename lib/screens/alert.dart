import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/utils/date.dart';
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

  void fetchEvent() async {
    print('Fetching event...');
    String eventId = widget.eventId;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    http.get(Uri.parse('$apiUrl/event/$eventId'), headers: { 'Authorization': 'Bearer $token' }).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          event = jsonDecode(response.body);
        });
      } else {
        if (response.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Register()));
        }
        print(response.statusCode);
      }
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
    http.post(
        Uri.parse('$apiUrl/event/${widget.eventId}/answer'), body: body, headers: {
          'Authorization': 'Bearer $token'
    })
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
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
            Text(dateFormat.format(DateTime.parse(event['start'])) ?? '', style: const TextStyle(fontSize: 20)),
            Text(dateFormat.format(DateTime.parse(event['end'])) ?? '', style: const TextStyle(fontSize: 20)),
            const SizedBox(
              height: 20,
            ),
            Text(event['comment'] ?? '',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        setAvailability(context, true);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.green),
                        foregroundColor:
                        MaterialStateProperty.all(Colors.white),
                      ),
                      child: const Text('Disponible'),
                    )),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        setAvailability(context, false);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        foregroundColor:
                        MaterialStateProperty.all(Colors.white),
                      ),
                      child: const Text('Non disponible'),
                    )),
              ],
            ),
            ElevatedButton(
              onPressed: () =>
                  launchUrlString(event['eProtecLink'] ?? '',
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
