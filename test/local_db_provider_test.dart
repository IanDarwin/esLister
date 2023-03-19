import 'package:eslister/data/local_db_provider.dart';
import 'package:eslister/model/item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  var _db = LocalDbProvider();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('insert and find', () async {
    await _db.open(inMemoryDatabasePath);
    var item = Item("Picasso Nose", []);
    Item ret = await(_db.insert(item));
    Item? found = await _db.getItem(ret.id!);
    expect(item.name, found!.name);
  });
}