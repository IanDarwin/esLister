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
  static final Set<String> locations = {
    "Bedroom-Main",
    "Bedroom-2",
    "Kitchen",
    "Living Room",
    "Office-1",
    "Office-2",
  };

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

  void _takePicture() async {
    print("ADD CODE TO TAKE PICTURE");
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
                        keyboardType: TextInputType.name,
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
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Description'),
                        onSaved: (value) {
                          _description = value;
                        },
                      ),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          var ret = locations
                              .where((String locn) => locn.toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase())
                          );
                          return ret;
                        },
                        fieldViewBuilder: (context, editingController, focusNode, onFieldSubmitted) {
                          if (_location != null && _location!.isNotEmpty) {
                            editingController.text = _location!;
                          }
                          return TextFormField(
                            controller: editingController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(labelText: 'Location'),
                            focusNode: focusNode,
                            onFieldSubmitted: (loc) {
                              onFieldSubmitted();
                              _location = loc;
                            },
                            onSaved: (loc) {
                              _location = loc;
                              locations.add(loc!);
                            },
                          );
                        },
                        onSelected: (String loc) {
                          print("onSelected($loc)");
                          _location = loc;
                          locations.add(loc);
                        },
                      ),
                      TextFormField(
                        initialValue: _value != null ? _value.toString() : '',
                        decoration: InputDecoration(labelText: 'Value'),
                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
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
                                if (index == _images.length) { // e.g., last one
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        const Text("Add Image"),
                                        GestureDetector(
                                          onTap: () async {
                                            _takePicture();
                                          },
                                          child: Container(
                                            width: 100.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: const Icon(Icons.camera),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            _addImage();
                                          },
                                          child: Container(
                                            width: 100.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: const Icon(Icons.image_search),
                                          ),
                                        ),
                                    ],
                                    )
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
