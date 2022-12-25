

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../screens/register.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Protection des données'),
            onTap: () {
              launchUrlString('https://protec-api.cchampou.me/privacy-policy',
                mode: LaunchMode.platformDefault,
              );
            },
          ),
          ListTile(
            title: const Text('Déconnexion'),
            onTap: () async {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'token');
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Register()));
            },
          ),
        ],
      ),
    );
  }
}
