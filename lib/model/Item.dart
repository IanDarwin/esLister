
/// Describe one item in the location being assessed
class Item {
  int? id = 0;
  String name;
  List<String> images = [];
  String? description;
  String? location;
  double? value;

  Item(this.name, this.images, {this.id, this.description, this.location, this.value});

  @override
  toString() {
    return "Item #$id Named $name";
  }

  Map<String,dynamic> toMap() {
    var map =  {
      "name": name,
      "images": images.toString(),
      "description": description,
      "location": location,
      "value": value,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  static Item fromMap(Map map) {
    String imList = (map['images'] != null) ? map['images'] : "[]";
    return Item(
      map['name'],
      stringToImageNameList(imList),
      id: map['id'],
      location: map["location"],
      description: map['description'],
      value: map['value'],
    );
  }

  // Convert List<String> of filenames to valid JSON String
  static String imageNameListToString(List<String> list) {
    var sb = StringBuffer('{"images":["');
    sb.writeAll(list, '","');
    sb.write('"]}');
    String ret = sb.toString();
    print('imageNameListToString: $ret');
    return ret;
  }
  // Convert the imageNameListToString()ed form of a List<String> back into the List.
  static List<String> stringToImageNameList(String raw) {
    if (raw.isEmpty || "[]" == raw) {
      return [];
    }
    // 11 = strlen(-->'{"images": <--);
    String raw2 = raw.substring(9, raw.length - 1);
    List<String> borked = raw2.substring(1, raw2.length - 1).split('","');
    print("Broken has ${borked.length} items: $borked");
    for (int i = 0; i < borked.length; i++) {
      borked[i] = borked[i].trim();
    }
    return borked;
  }
}