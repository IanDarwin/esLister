import 'package:eslister/main.dart' show localDbProvider;
import 'package:eslister/model/item.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/ui/item_page.dart';
import 'package:eslister/ui/nav_drawer.dart';

import 'package:flutter/material.dart';

const noDataMessage = "Nothing catalogued yet. Use + to add.";

/// Displays a list of Items.
class ItemListView extends StatefulWidget {
  const ItemListView({super.key});

  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => ItemListViewState();
}

class ItemListViewState extends State<ItemListView> {
  late Offset _pos = Offset.zero;
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
                  if ((snapshot.data as List<Item>).isEmpty) {
                    return const Center(child: Text(noDataMessage));
                  }
                  return Column(children: snapshot.data!.map((item) =>
                      GestureDetector(
                        onTapDown: (pos) {_getTapPosition(pos);},
                        onLongPress: () async {
                          final RenderObject? overlay =
                            Overlay.of(context).context.findRenderObject();
                          await showMenu(
                            context: context,
                            position: RelativeRect.fromRect(
                                Rect.fromLTWH(_pos.dx, _pos.dy, 50, 50),
                                Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                                    overlay.paintBounds.size.height)),
                            items: <PopupMenuEntry>[
                              PopupMenuItem(
                                onTap: () async => _edit(context, item),
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.edit),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                enabled: false,
                                onTap: () async => _doUpload(context, item),
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.delete),
                                    Text("Upload"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () async => _delete(context, item),
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.delete),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child:ListTile(
                        title: Text(item.name),
                        leading: const Icon(Icons.table_bar),
                        onTap: () => _edit(context, item),
                    ),
                  )
                ).toList(),
                );
                }
                if (snapshot.hasError) {
                  debugPrint("ERROR IN DB: ${snapshot.error}");
                  debugPrint(snapshot.stackTrace.toString());
                  return Center(child: Text("ERROR IN DB; ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text(noDataMessage));
                }
                // Still here, must be still in progress...
                return const CircularProgressIndicator();
              },
            ),
          ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.restorablePushNamed<Item>(
              context,
              ItemPage.routeName,
            );
            setState(() {
              print("Add Action::setState");
              // empty, but do trigger rebuild
            });
          },
          child:  const Icon(Icons.add)
      ),
    );
  }

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _pos = referenceBox.globalToLocal(tapPosition.globalPosition);
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
      print("Not mounted!!");
      return;
    }
    setState(() {});
  }

  _delete(context, item) async {
    debugPrint("Delete $item");
    await Future.delayed(
        const Duration(seconds: 0),
            () async => await localDbProvider.delete(item.id));
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  _doUpload(context, item) async {
    print("Upload capability not written yet");
  }

  alert(context, message, {title: 'Alert'}) {
    print(message);
  }
}
