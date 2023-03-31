import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:eslister/model/item.dart';
import 'package:eslister/provider/item_provider.dart';
import 'package:eslister/provider/project_provider.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/ui/item_edit_page.dart';
import 'package:eslister/ui/nav_drawer.dart';
import 'package:eslister/ui/project_list_page.dart';

const noDataMessage = "Nothing catalogued yet. Use + to add.";

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
    int pid = Provider.of<ItemProvider>(context).currentProjectId;
    var list = context.watch<ItemProvider>().getItemsInProject(targetProject: pid);
    print('ItemListView::build(): pid = $pid');
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
              itemCount: list.length,
              itemBuilder: (context, index) {
                Item item = list[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(shortForm(item.description!, 65)),
                  leading: const Icon(Icons.table_bar),
                  onTap: () async => _edit(context, item),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            // must tap a button to dismiss
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("Really Delete ${item.name}?"),
                                  content: Text(
                                      "Are you sure you want to permanently "
                                          "delete ${item.name}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteItem(item);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Really delete"),
                                    ),
                                  ]
                              );
                            });
                      }
                  ),
                );
              },
            );
          }
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
                        setState( () => Provider.of<ItemProvider>(context,
                            listen: false).currentProjectId = projects[index-1].id!);
                        print('ItemListViewState.build.BottomNav: provider.currentProjectID set to ${projects[index-1].id}');
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
                builder: (context) => ItemPage(item: Item('', [],
                    projectId: Provider.of<ItemProvider>(context, listen: false)
                        .currentProjectId))));
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
  Future<void> _edit(context, item) async {
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

  _doUpload(context, item) async {
    alert(context, "Upload capability not written yet", title: 'Sorry, but...');
  }

  alert(context, message, {title = 'Alert'}) {
    print(message);
  }

  String shortForm(String s, int len) {
    return s.length <= len ?
    s :
    '${s.substring(0, len - 3)}...';
  }
}
