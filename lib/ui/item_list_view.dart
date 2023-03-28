import 'package:eslister/main.dart' show localDbProvider;
import 'package:eslister/model/item.dart';
import 'package:eslister/provider/item_provider.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/ui/item_page.dart';
import 'package:eslister/ui/nav_drawer.dart';
import 'package:eslister/ui/project_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/project_provider.dart';

const noDataMessage = "Nothing catalogued yet. Use + to add.";

int currentProjectId = 1;

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
    var projects = context.watch<ProjectProvider>().projects;
    var list = context.watch<ItemProvider>().items;
    print('ItemListView::build()');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Items'),
        backgroundColor: Colors.lightBlueAccent,
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
      body:
        list.isEmpty ?
          const Center(child: Text(noDataMessage)) :
          Consumer<ItemProvider>(
            builder: (context, provider, child) {
            return ListView.builder(
          itemCount: provider.items.length, 
              itemBuilder: (context, index) {
                Item item = provider.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description!),
                  leading: const Icon(Icons.table_bar),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => provider.deleteItem(item.id!),
                  ),
                  onTap: () => _edit(context, item),
                );
              });
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlueAccent,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 50,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1 + (projects.length),
              itemBuilder: (context, index) {
            if (index == 0) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => (const ProjectListPage())));
                },
                  child: const Icon(Icons.edit),
              );
            } else {
              return ElevatedButton(
                onPressed: () {
                  if (projects[index-1].id == null) {
                    print("ARGHHH. Project ${projects[index-1]} is NULL");
                    return;
                  }
                  setState( () => currentProjectId = projects[index-1].id!);
                },
                child: Text(projects[index-1].name),
              );
            }
              }
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ItemPage(item: Item('', [], projectId: currentProjectId))));
            if (!mounted) {
              return;
            }
            setState(() {
              // empty, but do trigger rebuild
            });
          },
          child:  const Icon(Icons.add)
      ),
    );
  }

  // The PopupMenuItem.onTap does its own Navigator.pop,
  // so we use Future.delayed() to "delay" around the pop.
  _edit(context, item) async {
    print("Edit $item");
    await Future.delayed(
        const Duration(seconds: 0),
            () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ItemPage(item: item))));
    if (!mounted) {
      print("Not mounted.");
      return;
    }
    setState(() {});
  }

  _delete(context, item) async {
    debugPrint("Delete $item");
    await Future.delayed(
        const Duration(seconds: 0),
            () async => await localDbProvider.deleteItem(item.id));
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  _doUpload(context, item) async {
    alert(context, "Upload capability not written yet", title: 'Sorry, but...');
  }

  alert(context, message, {title = 'Alert'}) {
    print(message);
  }
}
