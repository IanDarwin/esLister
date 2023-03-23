/// "Export" some files into a Zip file

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';

Future<void> exportToZip() async {
  // Create the ZIP archive
  final archive = Archive();

  List<Project> projects = await localDbProvider.getAllProjects();

  for (Project proj in projects) {
    print('Project $proj');
    for (int itemId in proj.items) {
      print('Item $itemId in project ${proj.id}');
      Item? item = await localDbProvider.getItem(itemId);
      var generatedString = json.encode(item!.toMap());
      archive.addFile(
        ArchiveFile('${item.name}.txt',
            generatedString.length, generatedString.codeUnits),
      );

      for (String imageFileName in item.images) {
        var shortName = imageFileName.replaceAll(".*/", "");
        archive.addFile(
          ArchiveFile('images/$shortName',
              await File(imageFileName).length(), await File(imageFileName).readAsBytes()),
        );
      }
    }
  }

  // Save the ZIP archive to a file
  // XXX use package to find portable location for this!
  // final Directory appDocsDir = await getApplicationDocumentsDirectory();
  final Directory appDocsDir = Directory("/sdcard/download");
  var fullPath = "${appDocsDir.path}/archive.zip";
  final zipFile = File(fullPath);
  zipFile.writeAsBytesSync(ZipEncoder().encode(archive)!);

  print("Archive written to $fullPath");
}

