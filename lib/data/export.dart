/// "Export" some files into a Zip file

import 'package:eslister/provider/item_provider.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ExportPage extends StatefulWidget {

  const ExportPage({super.key});

  @override
  State<StatefulWidget> createState() => ExportPageState();
}

class ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    int projectId;
    projectId = Provider.of<ItemProvider>(context).currentProjectId; // XXX Have a chooser!

    return Scaffold(
      appBar: AppBar(title: Text('Export')),
        body:Center(
          // Need a Project chooser here
          // Need a filename textfield here.
          child: ElevatedButton(
            onPressed: () async {
              // find portable location for this!
              final Directory? appDocsDir = await getExternalStorageDirectory();
              var fullPath = "${appDocsDir!.path}/archive.zip";
              print('File path $fullPath');
              await exportToZip(projectId, fullPath);

              if (!mounted) {
                return;
              }
              Navigator.pop(context, fullPath);
            },
            child: const Text('Export'),
          ),
        )
    );
  }
}

final pathShortenerRegExp = RegExp(".*/");

Future<void> exportToZip(int projectId, String fullPath) async {
  print("Exporting project #$projectId to $fullPath");
  Project proj = await localDbProvider.getProject(projectId);

  /// The image names get shortened, and the images written
  /// to "image" in, the generated archive, so the archive can
  /// easily be used on the host computer.

  final archive = Archive();

  for (int itemId in proj.items) {
    // print('Item $itemId in project ${proj.id}');
    Item? item = await localDbProvider.getItem(itemId);
    Item? original = await localDbProvider.getItem(itemId); // item!.clone();
    for (int i = 0; i < item!.images.length; i++) {
      item.images[i] = item.images[i].replaceFirst(pathShortenerRegExp, "images/");
    }
    var generatedString = json.encode(item.toMap());
    archive.addFile(
      ArchiveFile('${item.name}.txt',
          generatedString.length, generatedString.codeUnits),
    );

    for (String imageFileName in original!.images) {
      var shortName = imageFileName.replaceAll(pathShortenerRegExp, "images/");
      archive.addFile(
        ArchiveFile(shortName,
            await File(imageFileName).length(), await File(imageFileName).readAsBytes()),
      );
    }
  }

  // Save the ZIP archive to a file
  final zipFile = File(fullPath);
  zipFile.writeAsBytesSync(ZipEncoder().encode(archive)!);


}

