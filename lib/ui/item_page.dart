import 'dart:io';
import 'package:flutter/material.dart';

import 'package:eslister/model/item.dart';
import 'package:image_picker/image_picker.dart';

/// Displays/Edits detailed information about one Item.
class ItemPage extends StatefulWidget {
  final Item item;
  static const routeName = '/item';
  const ItemPage({super.key, required this.item});

  @override
  ItemPageState createState() => ItemPageState();
}

class ItemPageState extends State<ItemPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  late List<String> _images ;
  String? _description;
  String? _location;
  double? _value;
  final Set<String> locations = {};

  @override
  void initState() {
    super.initState();
    _name = widget.item.name;
    _images = widget.item.images;
    _description = widget.item.description;
    _location = widget.item.location;
    _value = widget.item.value;
  }

  void _saveForm() {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    Item newItem = Item(
      _name!,
      _images,
      description: _description,
      location: _location,
      value: _value,
    );
    newItem.images = _images!;
    Navigator.of(context).pop(newItem);
  }

  void _addImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image.path);
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.item.name.isEmpty ? 'Add Item' : 'Edit Item'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value;
                        },
                      ),
                      Autocomplete(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          print("OptionsBuilder!");
                          return locations
                              .where((String loc) => loc.toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase())
                          )
                              .toList();
                        },
                        fieldViewBuilder: (context, editingController, focusNode, onFieldSubmitted) {
                          print("fieldViewBuilder!");
                          return TextFormField(
                            initialValue: _location,
                            decoration: InputDecoration(labelText: 'Location'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _location = value;
                            },
                          );
                        },
                        onSelected: (String loc) {
                          locations.add(loc);
                        },
                      ),
                      TextFormField(
                        initialValue: _value != null ? _value.toString() : '',
                        decoration: InputDecoration(labelText: 'Value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return null;      // field is optional
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _value = (value == null || value.isEmpty) ?
                          0 :
                          double.parse(value);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Text('Images'),
                      const SizedBox(height: 8.0),
                      SizedBox(
                          height: 100.0,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 1 + (_images.length),
                              itemBuilder: (context, index) {
                                if (index == _images.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        _addImage();
                                      },
                                      child: Container(
                                        width: 100.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Stack(
                                        children: [
                                          Container(
                                            width: 100.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: Image.file(
                                              File(_images[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () => _deleteImage(index),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(50.0),
                                                ),
                                                child: const Icon(Icons.close,
                                                    size: 16.0, color: Colors.grey),
                                              ),
                                            ),
                                          ),

                                        ]
                                    )
                                );
                              }
                          )
                      ),
                      ElevatedButton(
                        onPressed: () => _saveForm(),
                        child: Text("Save"),
                      ),
                    ]
                )
            )
        )
    );
  }
}
