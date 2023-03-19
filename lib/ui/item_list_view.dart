import 'package:eslister/model/item.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/ui/item_page.dart';
import 'package:flutter/material.dart';

import '../main.dart' show localDbProvider;
import 'nav_drawer.dart';

/// Displays a list of Items.
class ItemListView extends StatelessWidget {
  const ItemListView({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    var all = localDbProvider.getAllItems();
    print('ItemListView::build()');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body:  ListView(
          children: [
            FutureBuilder<List<Item>>(
              future: all,
              builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                if (snapshot.hasData) {
                  return Column(children: snapshot.data!.map((item) =>
                    ListTile(
                        title: Text('Item ${item.name}'),
                        leading: const CircleAvatar(
                          // Display the logo image asset.
                          foregroundImage: AssetImage('assets/img/logo.png'),
                        ),
                        onTap: () {
                          Navigator.restorablePushNamed(
                            context,
                            ItemPage.routeName,
                          );
                        }
                    )
                ).toList(),
                );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("ERROR IN DB; ${snapshot.error}"));
                }
                // Still here, so must be still in progress...
                return const CircularProgressIndicator();
              },
            ),
          ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () { Navigator.restorablePushNamed<Item>(
            context,
            ItemPage.routeName,
          );
          },
          child:  const Icon(Icons.add)
      ),
    );
  }
}
