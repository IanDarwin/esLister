import 'package:eslister/data/local_db_provider.dart';
import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  var db = LocalDbProvider();
  await db.open(inMemoryDatabasePath);
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('insert and find Item', () async {
    var item = Item("Picasso Nose", []);
    Item ret = await(db.insertItem(item));
    Item? found = await db.getItem(ret.id!);
    expect(item.name, found!.name);
  });
  test('insert and find Project', () async {
    var project = Project(id: 0, name: "Cheap Junk");
    Project ret = await(db.insertProject(project));
    List<Project>? found = await db.getAllProjects();
    Project added = found.last;
    expect(project.name, added!.name);
  });
}