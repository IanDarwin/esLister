class Project {
  int? id;
  late String name;
  String? description;
  final List<int> items = [];

  Project({required this.id, required this.name, this.description});

  @override
  toString() {
    return 'Project#$id-$name';
  }

  Map toMap() {
    return {
      "id": id,
      "name": name,
      'description': description,
    };
  }

  static Project fromMap(Map map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  void addItemId(m) {
    items.add(m);
  }
}
