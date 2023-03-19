/// Data Access for entity Data

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:eslister/model/item.dart';

const itemTableName = 'items';
const columnId = 'id';
const columnRemoteId = "remoteId";
const columnName = 'name';
const columnDescr = 'description';
const columnLocation = 'location';
const columnValue = 'value';
const allColumns = [columnId, columnRemoteId, columnName, columnDescr, columnLocation, columnValue];

/// Local Data provider.
class LocalDbProvider {

  /// The database when opened.
  late Database _db;

  /// Open the database.
  Future<void> open(String path) async {
    debugPrint("LocalDbProvider.open($path)");
    _db = await openDatabase(path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    debugPrint("In LocalDbProvider::onCreate; database = $database");
    await database.execute('''
create table $itemTableName ( 
  $columnId integer primary key autoincrement,
  $columnRemoteId text,
  $columnName text not null,
  $columnDescr text,
  $columnLocation text,
  $columnValue double
  )
''');
    // Insert starter records
    for (Item item in _demoList) {
      await database.execute('''
        insert into $itemTableName($columnName,$columnDescr,$columnLocation,$columnValue)
        values('${item.name}', '${item.description}', '${item.location}', ${item.value});
        ''');
    }
  }

  Future<void> _onUpgrade(Database base, int oldVersion, int newVersion) async {
    throw(Exception("onUpgrade not needed yet"));
  }

  // Initial starter list
  final List<Item> _demoList = [
    Item('Candlestick', [], location: 'Living room', description:"A single silver candlestick (heavy)", value: 1.50),
    Item('Rope', [], location: 'Parlor', description:"A 10-foot long sisal rope", value: 0.25),
    Item('Knife', [], location: 'Kitchen', description:"A long and very sharp knife"),
  ];

  // CRUD operations:

  /// "Create": Insert an entity.
  Future<Item> insert(Item item) async {
    debugPrint("LocalDbProvider::inserting $item");
    var map = item.toMap();
    map.remove("id");
    map.remove("images");
    int id = await _db.insert(itemTableName, map);
    item.id = id;
    print("Insert returning item #${item.id}, name ${item.name}");
    return item;
  }

  /// "Read": Get an entity
  Future<Item?> getItem(int id) async {
    final List<Map> maps = await _db.query(itemTableName,
        columns: allColumns,
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieve all the entity entries in the table.
  Future<List<Item>> getAllItems() async {
    List<Item> result = [];
    final List<Map> maps = await _db.query(itemTableName,
        orderBy: 'lower($columnName)');
    for (Map m in maps) {
      result.add(Item.fromMap(m));
    }
    print('getAllItems found ${maps.length} items and created ${result.length} Item objcts');
    return result;
  }

  /// "Update" an entity.
  Future<int?> update(Item item) async {
    return await _db.update(itemTableName, item.toMap(),
        where: '$columnId = ?', whereArgs: [item.id]);
  }

  /// "Delete" an entity.
  Future<int?> delete(int id) async {
    return await _db.delete(itemTableName, where: '$columnId = ?', whereArgs: [id]);
  }

  // List<String> get categories => _locations;

  /// Close database.
  Future close() async => _db.close();
}
