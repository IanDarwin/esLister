import 'package:catalog/model/item.dart';
import 'package:catalog/settings/settings_view.dart';
import 'package:catalog/ui/item_page.dart';
import 'package:flutter/material.dart';

/// Displays a list of Items.
class ItemListView extends StatelessWidget {
  ItemListView({super.key, required this.items});

  static const routeName = '/';

  List<Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      items.add(Item("No entries, add some!"));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'ItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
            title: Text('Item ${item.name}'),
            leading: const CircleAvatar(
              // Display the Flutter Logo image asset.
              foregroundImage: AssetImage('assets/images/flutter_logo.png'),
            ),
            onTap: () {
              // Navigate to the details page. If the user leaves and returns to
              // the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(
                context,
                ItemPage.routeName,
              );
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () { print("TODO write add"); },
          child:  const Icon(Icons.add)

      ),
    );
  }
}
