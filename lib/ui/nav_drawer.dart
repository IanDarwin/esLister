import 'package:eslister/ui/project_list_page.dart';
import 'package:flutter/material.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/data/export.dart';
import 'package:eslister/main.dart' show settingsController;

import 'dialog_demos.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<StatefulWidget> createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
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
              leading: const Icon(Icons.cloud),
              title: const Text('Export Project'),
              onTap: () async {
                String fullPath = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExportPage()));
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pop();  // close the nav drawer
                alert(context, "Archive written; use adb pull $fullPath", title: "Export done");
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
