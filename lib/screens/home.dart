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
  final pendingEvents = [];
  final otherEvents = [];


  Future<void> fetchEvents() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token == null && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Register()));
      return;
    }
    http.Response response =
        await http.get(Uri.parse('$apiUrl/event'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List events = jsonDecode(response.body);
      setState(() {
        pendingEvents.clear();
        otherEvents.clear();
        pendingEvents.addAll(events.where((event) => event['selfAvailability'] == 'pending'));
        otherEvents.addAll(events.where((event) => event['selfAvailability'] != 'pending'));
      });
    } else {
      if (response.statusCode == 401 && mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Register()));
      }
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
      appBar: appBar(),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: pendingEvents.isEmpty && otherEvents.isEmpty
              ? const Welcome()
              : RefreshIndicator(
                  onRefresh: fetchEvents,
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Nécessite votre attention', style: TextStyle(fontSize: 24)),
                      ),
                      ...pendingEvents.map((event) {
                        return EventCard(
                          event: event,
                          refresh: fetchEvents,
                        );
                      }).toList(),
                      pendingEvents.isEmpty ? const Text('Aucun') : Container(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Historique', style: TextStyle(fontSize: 24)),
                      ),
                      ...otherEvents.map((event) {
                        return EventCard(
                          event: event,
                          refresh: fetchEvents,
                        );
                      }).toList(),
                      otherEvents.isEmpty ? const Text('Aucun') : Container(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
