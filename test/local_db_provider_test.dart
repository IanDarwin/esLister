import 'package:eslister/data/local_db_provider.dart';
import 'package:eslister/model/item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  var db = LocalDbProvider();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('insert and find', () async {
    await db.open(inMemoryDatabasePath);
    var item = Item("Picasso Nose", []);
    Item ret = await(db.insert(item));
    Item? found = await db.getItem(ret.id!);
    expect(item.name, found!.name);
  });
}