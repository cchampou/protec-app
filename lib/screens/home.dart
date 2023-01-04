import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protec_app/components/app_bar.dart';
import 'package:protec_app/components/event_card.dart';
import 'package:protec_app/components/welcome.dart';
import 'package:protec_app/screens/register.dart';
import 'package:protec_app/components/drawer.dart';
import 'package:protec_app/utils/fetch.dart';

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
    try {
      final json = await getFromApi(path: '/event');
      final events = json["payload"];
      setState(() {
        pendingEvents.clear();
        otherEvents.clear();
        pendingEvents.addAll(
            events.where((event) => event['selfAvailability'] == 'pending'));
        otherEvents.addAll(
            events.where((event) => event['selfAvailability'] != 'pending'));
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
                        child: Text('Nécessite votre attention',
                            style: TextStyle(fontSize: 24)),
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
                        child:
                            Text('Historique', style: TextStyle(fontSize: 24)),
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
