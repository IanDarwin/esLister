import 'package:flutter/material.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/main.dart' show settingsController;

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  build(context) {
    return Drawer(
      child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.none,
                      image: AssetImage('assets/img/logo.png'))
              ),
              child: Text(
                'Lister Menu',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.input),
              title: const Text('Lister Intro/Help'),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SettingsView(controller: settingsController)))
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info),
              applicationName:  'Bookmarks',
              aboutBoxChildren: [
               Text("Bookmarks for Flutter"),
              ],
            ),
          ]),
    );
  }
}
