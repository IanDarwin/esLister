/// "Export" some files into a Zip file

import 'dart:convert';
import 'dart:typed_data';

import 'package:eslister/provider/item_provider.dart';
import 'package:eslister/provider/project_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';
import 'package:provider/provider.dart';

import 'package:eslister/main.dart' show appDocsDir, localDbProvider;

class ImportPage extends StatefulWidget {
  final String fullPath;
  final String format;

  const ImportPage({ required this.fullPath, required this.format, super.key});

  @override
  State<StatefulWidget> createState() => ImportPageState();
}

class ImportPageState extends State<ImportPage> {
  final ZipDecoder decoder = ZipDecoder();

  @override
  Widget build(BuildContext context) {
    var projects = context
        .watch<ProjectProvider>()
        .projects;
    String format = 'JSON';

    return Scaffold(
      appBar: AppBar(title: const Text('Re-Import')),
      body: Center( // XXX Need a filename textfield here?
        child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    doImport(widget.fullPath, widget.format);
                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Import")
              )
            ]
        ),
      ),
    );
  }

  final outdir = "/sdcard/Downloads/";

  void doImport(String fullPath, String format) {
    print("Doing import from $fullPath as $format");
    File file = File(fullPath);
    Uint8List bytes = file.readAsBytesSync();
    final Archive archive = decoder.decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        if (filename.endsWith(".txt")) {
          // Mistakenly wrote JSON files as .txt, not .json
          final data = file.content as List<int>;
          final dataString = String.fromCharCodes(data);
          Map<String, dynamic> itemMap = jsonDecode(dataString);
          final item = Item.fromMap(itemMap);
          print('File contains $item');
          Provider.of<ItemProvider>(context, listen:false).insertItem(item);
        } else if (filename.endsWith("html")) {
          // For JSON, do nothing with index.html
        } else {
          print("Binary file $filename");
        }
      }
      // else it'a directory, which we ignore
      // we never write symlinks so they /*CANTHAPPEN*/
    }
  }
}