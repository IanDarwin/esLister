/// "Export" some files into a Zip file

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

import 'package:eslister/model/Item.dart';
import 'package:eslister/model/project.dart';
import 'package:eslister/data/local_db_provider.dart';

import '../main.dart';

void exportToZip() async
{
  // Create the ZIP archive
  final archive = Archive();

  List<Project> projects = await localDbProvider.getAllProjects();

  for (Project proj in projects) {

    for (Item item in proj.items()) {

      var generatedString = json.encode(item.toMap());
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
  final zipFile = File('/sdcard/archive.zip');
  zipFile.writeAsBytesSync(ZipEncoder().encode(archive)!);
}

