
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
      "images": imageNameListToString(images),
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

  /// Convert List<String> of filenames to valid JSON String
  static String imageNameListToString(List<String> list) {
    var sb = StringBuffer('{"images":["');
    sb.writeAll(list, '","');
    sb.write('"]}');
    String ret = sb.toString();
    return ret;
  }

  /// Convert the imageNameListToString()ed form of a List<String> back into the List.
  /// Did not want to load a JSON parsr for s/t this simple, so do by hand
  /// (Revisit that when JSON moves into the neighborhood).
  static List<String> stringToImageNameList(String input) {
    if (input.isEmpty || "[]" == input) {
      return [];
    }
    // input is: {"images":["/data/user/0/com.darwinsys/cache/CAP86.jpg","/data/user/0/com.darwinsys/cache/CAP87.jpg"]}
    String value = input.substring(10, input.length - 1);
    // Value should now be: ["/data/user/0/com.darwinsys/cache/CAP86.jpg","/data/user/0/com.darwinsys/cache/CAP87.jpg"]
    List<String> broken = value.substring(1, value.length - 1).split('","');
    for (int i = 0; i < broken.length; i++) {
      broken[i] = broken[i].trim().replaceAll('"', '');
    }
    return broken;
  }
}