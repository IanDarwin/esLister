import 'package:eslister/ui/project_list_page.dart';
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
                      scale: 3.0,
                      fit: BoxFit.none,
                      image: AssetImage('assets/img/logo.png'))
              ),
              child: Text(
                '        esLister Menu',
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.input),
              title: const Text('Lister Intro/Help'),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Projects'),
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const ProjectListPage()))
              },
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
              applicationName:  'esLister',
              aboutBoxChildren: [
               Text("Flutter Lister"),
                Text("An app to prepare catalog listings for event sales, yard sales, or selling on auction sites"),
              ],
            ),
          ]),
    );
  }
}
