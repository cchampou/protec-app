import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protec_app/components/app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:protec_app/components/event_card.dart';
import 'package:protec_app/components/welcome.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/components/drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  final events = [];

  Future<void> fetchEvents() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token == null && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Register()));
      return;
    }
    print(token);
    http.Response response = await http.get(Uri.parse('$apiUrl/event'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      setState(() {
        events.clear();
        events.addAll(jsonDecode(response.body));
      });
      print(events);
    } else {
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Accueil'),
      drawer: const CustomDrawer(),
      body: Center(
        child: events.isEmpty
            ? const Welcome()
            : RefreshIndicator(
                onRefresh: fetchEvents,
                child: ListView(
                  children: events.map((event) {
                    return EventCard(event: event);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
