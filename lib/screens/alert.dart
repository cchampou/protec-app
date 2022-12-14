import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:protec_app/components/answer_buttons.dart';
import 'package:protec_app/screens/webview.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/utils/colors.dart';
import 'package:protec_app/utils/date.dart';
import 'package:protec_app/utils/event.dart';
import 'package:protec_app/utils/fetch.dart';
import 'package:http/http.dart' as http;

import 'package:protec_app/components/app_bar.dart';
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
    String eventId = widget.eventId;

    try {
      final json = await getFromApi(path: '/event/$eventId');
      final payload = json["payload"];
      final bool hasNotYetAnswered = payload["selfAvailability"] == 'pending';
      setState(() {
        event = payload;
        edit = hasNotYetAnswered;
        canCancel = !hasNotYetAnswered;
      });
    } catch (e) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Register()));
    }
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
    try {
      String token = await getTokenFromStorage();
      final response = await http.post(
          Uri.parse('$apiUrl/event/${widget.eventId}/answer'),
          body: body,
          headers: {'Authorization': 'Bearer $token'}).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: 'Nous avons bien pris en compte votre r??ponse',
              toastLength: Toast.LENGTH_LONG);
          fetchEvent();
        } else {
          throw Exception(response.statusCode);
        }
      });
    } catch (e) {
      print(e);
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Register()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      fetchEvent();
      return Scaffold(
        appBar: appBar(title: 'D??clenchement'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: appBar(title: 'D??clenchement'),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Ceci est un d??clenchement',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor)),
            const Text('Veuillez indiquer votre disponibilit??',
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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => WebViewScreen(
                        url: event['eProtecLink'], title: 'eProtec')));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Voir sur eProtec'),
            ),
          ]),
        ));
  }
}
