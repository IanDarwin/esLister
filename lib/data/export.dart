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
  final pathShortenerRegExp = RegExp(".*/");

  List<Project> projects = await localDbProvider.getAllProjects();

  // XXX Only do one project, make it a param

  /// The image names get shortened, and the images written
  /// to, the generated archive, so it can be used on the host computer
  for (Project proj in projects) {
    // print('Project $proj');
    for (int itemId in proj.items) {
      // print('Item $itemId in project ${proj.id}');
      Item? item = await localDbProvider.getItem(itemId);
      Item? original = await localDbProvider.getItem(itemId); // item!.clone();
      for (int i = 0; i < item!.images.length; i++) {
        item!.images[i] = item!.images[i].replaceFirst(pathShortenerRegExp, "images/");
      }
      var generatedString = json.encode(item!.toMap());
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

