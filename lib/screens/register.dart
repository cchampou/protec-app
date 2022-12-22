import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:protec_app/components/app_bar.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

const String apiUrl = 'https://protect-app.loca.lt/api';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isLoading = true;
  String _error = '';

  late TextEditingController _tokenController;

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    checkRegistration();
  }

  @override
  void dispose() {
    print('dispose');
    _tokenController.dispose();
    super.dispose();
  }

  checkRegistration() async {
    print('Checking registration...');
    final String? deviceId = await messaging.getToken();
    if (deviceId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    http.get(Uri.parse('$apiUrl/device/check/$deviceId')).then((response) {
      if (mounted == false) {
        return;
      }
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  registerDevice() async {
    setState(() {
      _isLoading = true;
    });
    String? deviceId = await messaging.getToken();
    http.post(Uri.parse('$apiUrl/device/register'),
        body: jsonEncode(<String, String?>{
          'registrationToken': _tokenController.value.text,
          'deviceId': deviceId
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).catchError((error) {
      setState(() {
        _isLoading = false;
        _error = 'Le code saisi est incorrect';
      });
    }).then((value) {
      setState(() {
        _isLoading = false;
        _error = 'Le code saisi est incorrect';
      });
      if (value.statusCode == 200) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Identification'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _isLoading
                ? [
                    const CircularProgressIndicator(),
                  ]
                : [
                    Text(
                      _error,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _tokenController,
                      onSubmitted: (value) {
                        registerDevice();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Entrez votre code',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: registerDevice,
                      child: const Text('Valider'),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
