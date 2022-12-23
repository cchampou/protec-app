import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:protec_app/screens/alert.dart';

import '../utils/date.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Map event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Image.asset(
              'images/protection_civile_logo.png',
              fit: BoxFit.contain,
            ),
            title: Text(event['title']),
            subtitle: Text(event['location'] + " - " + dateFormat.format(DateTime.parse(event['start']))),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => AlertScreen(eventId: event["_id"])));
            },
          ),
        ],
      ),
    );
  }
}
