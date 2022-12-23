import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/utils/date.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

import '../components/app_bar.dart';
import 'home.dart';
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
    http.get(Uri.parse('$apiUrl/event/$eventId')).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          event = jsonDecode(response.body);
        });
        print(event);
      } else {
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
    http.post(
        Uri.parse('$apiUrl/event/${widget.eventId}/answer'), body: body)
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
      } else {
        print(response.statusCode);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (event == null) {
      fetchEvent();
      return Scaffold(
        appBar: appBar('Alert'),
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
