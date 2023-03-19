import 'package:eslister/model/item.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/ui/item_page.dart';
import 'package:flutter/material.dart';

import '../main.dart' show localDbProvider;
import 'nav_drawer.dart';

/// Displays a list of Items.
class ItemListView extends StatefulWidget {
  const ItemListView({super.key});

  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => ItemListViewState();
}

class ItemListViewState extends State<ItemListView> {
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
                        title: Text(item.name),
                        leading: const Icon(Icons.table_bar),
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
                if (!snapshot.hasData) {
                  return Center(child: Text("Nothing catalogued yet. Use + to add."));
                }
                // Still here, must be still in progress...
                return const CircularProgressIndicator();
              },
            ),
          ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.restorablePushNamed<Item>(
            context,
            ItemPage.routeName,
            );
            setState(() {
              // empty, just trigger rebuild
            });
          },
          child:  const Icon(Icons.add)
      ),
    );
  }
}
