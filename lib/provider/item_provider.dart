
import 'package:flutter/material.dart';

import 'package:eslister/main.dart';
import 'package:eslister/model/item.dart';

class ItemProvider extends ChangeNotifier {
	List<Item> _items = [];

	ItemProvider() {
		_init();
	}

	_init() async {
		await _loadItems();
	}

	int getItemCount() {
		int i = 0;
		localDbProvider.getItemsInProject(1).then(
				(list) {
					i = list.length;
				}
		);
		return i;
	}

	/// Create, and notify
	Future<Item> insertItem(Item item) async {
		item = await localDbProvider.insertItem(item);
		_items.add(item);
		notifyListeners();
		return item;
	}

	/// Read (no notify)
	Item getItem(int id) {
		var list =  _items.where((itm) => itm.id == id);
		return list.first;
	}

	/// Read (no notify)
	List<Item> getItemsInProject(int projectId) {
		var iter = _items.where((itm) => itm.projectId == projectId);
		return iter.toList();
	}

	/// Read (no notify)
	List<Item> get items => _items;

	/// Update, and notify
	Future<void> updateItem(Item item) async {
		var rc = await localDbProvider.updateItem(item);
		final index = _items.indexWhere((i) => i.id == item.id);
		_items[index] = item;
		notifyListeners();
	}

	/// Delete, and notify
	Future<void> deleteItem(int id) async {
		 await localDbProvider.deleteItem(id);
		_items.removeWhere((i) => i.id == id);
		notifyListeners();
	}

	_loadItems() async {
		_items = await localDbProvider.getAllItems();
		notifyListeners();
	}
}
