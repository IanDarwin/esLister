import 'package:flutter_test/flutter_test.dart';

import 'package:eslister/model/item.dart';

void main() async {
  test('Item test', () {
    Item target = Item("Antique Soft", ['picture1.jpg'], value: 1000.00);

    expect(target.value, 1000.0);
    expect(target.images.length, 1);
  });
}
