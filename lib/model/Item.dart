
const emptyString = "";
const zero = 0.0;

class Item {
  String name;
  List<String>? images = [];
  String? description;
  String? location;
  double? value;

  Item(this.name, {images, description, location, value});
}