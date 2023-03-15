
const emptyString = "";


class Item {
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
}