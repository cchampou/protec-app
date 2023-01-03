import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protec_app/screens/about.dart';
import 'package:protec_app/screens/webview.dart';

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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => const WebViewScreen(
                      url: 'https://protec-api.cchampou.me/privacy-policy',
                      title: 'Politique de confidentialité')));
            },
          ),
          ListTile(
            title: const Text('À propos'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => AboutScreen()));
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
