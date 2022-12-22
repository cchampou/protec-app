import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:protec_app/screens/register.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

import '../components/app_bar.dart';
import 'home.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  AlertScreen({super.key, required this.message});

  final RemoteMessage message;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  void setAvailability(BuildContext context, bool availability) async {
    final body = {
      'availability': availability.toString(),
      'deviceId': await messaging.getToken(),
    };
    print(body);
    http.post(
        Uri.parse('$apiUrl/event/${message.data['eventId']}/answer'), body: body)
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      } else {
        print(response.statusCode);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
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
            Text(message.data['title'] ?? '',
                style:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text(message.data['location'] ?? '',
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
            Text(message.data['startDate'] + ' ' + message.data['startTime'] ??
                ''),
            Text(message.data['endDate'] + ' ' + message.data['endTime'] ?? ''),
            const SizedBox(
              height: 20,
            ),
            Text(message.data['comment'] ?? '',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
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
                  launchUrlString(message.data['eProtecLink'] ?? '',
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
