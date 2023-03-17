
/// Describe one item in the location being assessed
class Item {
  int? id;
  String name;
  List<String>? images = [];
  String? description;
  String? location;
  double? value;

  Item(this.name, {images, description, location, value});

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
        return Item(
          map['name'],
          location: map["location"],
          description: map['description'],
          value: map['value'],
        );
  }
}