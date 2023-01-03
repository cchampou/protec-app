import 'package:flutter/material.dart';

import 'package:protec_app/screens/alert.dart';

import '../utils/date.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.refresh});

  final Map event;
  final Function refresh;

  String getEmoji({ availability = 'pending' }) {
    switch (availability) {
      case 'pending':
        return '⏳ - Non-répondu';
      case 'accepted':
        return '✔️ - Disponible';
      case 'refused':
        return '❌ - Indisponible';
      default:
        return '🤔 - Réponse inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final availability = getEmoji(availability: event['selfAvailability']);
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Image.asset(
              'images/protection_civile_logo.png',
              fit: BoxFit.contain,
            ),
            title: Text(event['title'] + ' - ' + availability),
            subtitle: Text(event['location'] + " - " + dateFormat.format(DateTime.parse(event['start']))),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => AlertScreen(eventId: event["_id"]))).then((value) => refresh());
            },
          ),
        ],
      ),
    );
  }
}
