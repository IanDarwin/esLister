import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';

// Projects
var tableNameProjects = 'project';

// Items
const tableNameItems = 'items';
const columnId = 'id';
const columnRemoteId = "remoteId";
const columnName = 'name';
const columnProjectId = 'project_id';
const columnDescr = 'description';
const columnLocation = 'location';
const columnValue = 'value';
const columnImages = 'images';
const allColumns = [columnId, columnRemoteId, columnName, columnProjectId,
  columnDescr, columnLocation, columnValue, columnImages];

/// Local Data provider.
class LocalDbProvider {

  /// The database when opened.
  late Database _db;

  //////////////////////// DB SETUP/TEARDOWN /////////////////////

  /// Open the database.
  Future<void> open(String path) async {
    debugPrint("LocalDbProvider.open($path)");
    _db = await openDatabase(path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    // Insert any last-minute fixups here
    // int ret = await _db.rawUpdate('update $tableNameItems set project_id = 1');
    // print("update returned $ret");
  }

  Future<void> _onCreate(Database database, int version) async {
    debugPrint("In LocalDbProvider::onCreate; database = $database");
    await database.execute('''
create table $tableNameItems ( 
  $columnId integer primary key autoincrement,
  $columnRemoteId text,
  $columnProjectId int,
  $columnName text not null,
  $columnDescr text,
  $columnLocation text,
  $columnImages text,
  $columnValue double
  )
''');

    // Insert starter Items
    for (Item item in _demoItems) {
      await database.execute('''
        insert into $tableNameItems(
          $columnName, $columnProjectId, $columnDescr,$columnLocation,$columnValue)
        values('${item.name}', ${item.projectId},'${item.description}', '${item.location}', ${item.value});
        ''');
    }

    // Now the Projects table
    await database.execute('''
  create table $tableNameProjects (
    id integer primary key autoincrement,
    name text,
    description text
  )''');
    for (Project project in _demoProjects) {
      await database.execute('''
        insert into $tableNameProjects(id, name, description)
        values(${project.id}, '${project.name}', '${project.description}');
        ''');
    }
  }

  Future<void> _onUpgrade(Database base, int oldVersion, int newVersion) async {
    throw(Exception("onUpgrade not needed yet"));
  }

  //////////////////////// PRE-SEED DATA /////////////////////
  
  // Initial starter data
  final List<Item> _demoItems = [
    Item('Candlestick', [], projectId: 1, location: 'Living room', description:"A single silver candlestick (heavy)", value: 1.50),
    Item('Rope', [], projectId: 1, location: 'Parlor', description:"A 10-foot long sisal rope", value: 0.25),
    Item('Knife', [], projectId: 1, location: 'Kitchen', description:"A long and very sharp knife", value: 0),
  ];
  
  final List<Project> _demoProjects = [
    Project(id: 1, name: "Default Project", description: "A Sample Project"),
    Project(id: 2, name: "Estate Stuff", description: "Another Sample Project"),
    Project(id: 3, name: "Cheaper Stuff"),
  ];

  /// Close database.
  Future close() async => _db.close();

  //////////////////////// ITEMS /////////////////////

  /// "Create": Insert an entity.
  Future<Item> insertItem(Item item) async {
    debugPrint("LocalDbProvider::inserting $item");
    var map = item.toMap();
    map.remove("id"); // Let DB assign on insert
    map['images'] = item.images.toString();
    int id = await _db.insert(tableNameItems, map);
    item.id = id;
    return item;
  }

  /// "Read": Get an entity
  Future<Item?> getItem(int id) async {
    //debugPrint("LocalDbProvider getItem($id)");
    final List<Map> maps = await _db.query(tableNameItems,
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
    final List<Map> maps = await _db.query(tableNameItems,
        orderBy: 'lower($columnName)');
    for (Map m in maps) {
      result.add(Item.fromMap(m));
    }
    return result;
  }

  /// Retrieve all the entity entries in one project.
  Future<List<Item>> getItemsInProject(int project_id) async {
    List<Item> result = [];
    final List<Map> maps = await _db.query(tableNameItems,
        where: 'project_id = ?',
        whereArgs: [project_id],
        orderBy: 'lower($columnName)');
    for (Map m in maps) {
      result.add(Item.fromMap(m));
    }
    return result;
  }

  /// "Update" an Item.
  Future<int?> updateItem(Item item) async {
    var map = item.toMap();
    return await _db.update(tableNameItems, map,
        where: '$columnId = ?', whereArgs: [item.id]);
  }

  /// "Delete" an Item.
  Future<int?> deleteItem(int id) async {
    return await _db.delete(tableNameItems, where: '$columnId = ?', whereArgs: [id]);
  }

  //////////////////////// CATEGORIES /////////////////////
  // List<String> get categories => _locations;

  //////////////////////// PROJECTS /////////////////////
  Future<Project> insertProject(project) async {
    int id = await _db.insert(tableNameProjects, project.toMap());
    project.id = id;
    return project;
  }

  Future<int> updateProject(project) async {
    print('LocalDbProvider.updateProject $project');
    return await _db.update(tableNameProjects, project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
  }

  Future<Project> getProject(int projectId) async {
    var p = await _db.query(tableNameProjects,
      where: "id = ?",
      whereArgs: [projectId]);
    Project proj = Project.fromMap(p[0]);
    await _addItemsIntoProject(proj);
    return proj;
  }

  Future<List<Project>> getAllProjects() async {
    List<Project> result = [];
    final List<Map> projectMaps = await _db.query(tableNameProjects,
        orderBy: 'id');
    for (Map m in projectMaps) {
      var project = Project.fromMap(m);
      List<Map<String, dynamic>> itemsMap = await _addItemsIntoProject(project);
      print("Found ${itemsMap.length} items for $project");
      result.add(project);
    }
    return result;
  }

  Future<void> deleteProject(Project project) async {
    await _db.delete(tableNameProjects, where: 'id=?', whereArgs: [project.id]);
  }

  /// Add in the list of items from the items table that belong to this project
  Future<List<Map<String, dynamic>>> _addItemsIntoProject(Project project) async {
    List<Map<String,dynamic>> itemsMap = await _db.query(tableNameItems,
        columns: [columnId],
        where: "project_id = ?", whereArgs: [project.id]);
    for (Map m in itemsMap) {
      project.addItemId(m['id']);
    }
    return itemsMap;
  }
}
