import 'package:eslister/data/local_db_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eslister/model/item.dart';

void main() async {
  test('Item test', () {
    Item target = Item("Antique Soft", ['picture1.jpg'], value: 1000.00);

    expect(target.value, 1000.0);
    expect(target.images.length, 1);
  });

  test("Item.stringToImageNameList", () {
    var expected = ['pic1', 'pic2', 'image3.jpeg'];
    String input = '{images:["pic1","pic2","image3.jpeg"]';
    expect(Item.stringToImageNameList(input), expected);
  });

  test("Item.imageNameListToString", () {
    var input = ["foo", "bar", "meh"];
    var expected = '{"images":["foo","bar","meh"]}';
    expect(Item.imageNameListToString(input), expected);
  });
}
