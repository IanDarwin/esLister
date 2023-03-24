
/// Describe one item in the location being assessed
class Item {
  int? id = 0;
  String name;
  int projectId;
  List<String> images = [];
  String? description;
  String? location;
  double? value;

  Item(this.name, this.images, {this.id, this.projectId = 1, this.description, this.location, this.value});

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
      "project_id": projectId,
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
      projectId: map['project_id'],
    );
  }

  /// Convert List<String> of filenames to simple comma-separated string
  static String imageNameListToString(List<String> list) {
    var sb = StringBuffer();
    sb.writeAll(list, ',');
    String ret = sb.toString();
    return ret;
  }

  /// Inverse of imageNameListToString
  /// input should look like:
  /// /data/user/0/com.darwinsys/cache/CAP86.jpg,/data/user/0/com.darwinsys/cache/CAP87.jpg
  static List<String> stringToImageNameList(String input) {
    if (input.isEmpty || "[]" == input) {
      return [];
    }
    List<String> broken = input.split(',');
    for (int i = 0; i < broken.length; i++) {
      broken[i] = broken[i].trim();
    }
    return broken;
  }
}