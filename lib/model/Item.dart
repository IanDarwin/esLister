
/// Describe one item in the location being assessed
class Item {
  int? id;
  String name;
  List<String> images = [];
  String? description;
  String? location;
  double? value;

  Item(this.name, this.images, {this.description, this.location, this.value});

  Map<String,dynamic> toMap() {
    return {
      "name": name,
      "images": images,
      "description": description,
      "location": location,
      "value": value,
    };
  }

  static Item fromMap(Map map) {
    var m2 = Map();
    m2.addAll(map);
    return Item(
      m2['name'],
      m2['images'] ??= <String>[],
      location: m2["location"],
      description: m2['description'],
      value: m2['value'],
    );
  }
}