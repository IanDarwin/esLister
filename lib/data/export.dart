/// "Export" some files into a Zip file

import 'package:eslister/provider/item_provider.dart';
import 'package:eslister/provider/project_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:eslister/model/item.dart';
import 'package:eslister/model/project.dart';
import 'package:provider/provider.dart';

import 'package:eslister/main.dart' show appDocsDir, localDbProvider;

class ExportPage extends StatefulWidget {

  const ExportPage({super.key});

  @override
  State<StatefulWidget> createState() => ExportPageState();
}

class ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    int currentProjectId = Provider.of<ItemProvider>(context).currentProjectId;
    var projects = context.watch<ProjectProvider>().projects;
    String format = "?No format?";

    return Scaffold(
        appBar: AppBar(title: const Text('Export')),
        body:Center(// Need a filename textfield here.
          child: Column(
            children: [
              Row(
                  children: [
                    const Text("Project: "),
                    DropdownButton<int>(
                        value: currentProjectId,
                        items: projects.map((project) {
                          return DropdownMenuItem(
                              value: project.id,
                              child: Text(project.name));
                        }).toList(),
                        onChanged: (int? val)  {
                          setState(() {
                            Provider.of<ItemProvider>(context, listen: false).currentProjectId = currentProjectId = val!;
                          });
                        }),
                  ]
              ),

              Text("Directory is $appDocsDir"),
              const Text("Format (FOR NOW, ONLY HTML): "),
              Row(
                  children: [
                    const Text("JSON"),
                    Radio<String>(
                      groupValue: format,
                      value: 'JSON',
                      onChanged: (val){
                        print("Igli was here: val=${val}");
                        //setState(() {
                          format = val!;
                       //});
                      },
                    ),
                    const Text("HTML"),
                    Radio<String>(
                      groupValue: format,
                      value: 'HTML',
                      onChanged: (val){
                        print("Igli was here!");
                        //setState(() {
                          format = val!;
                        //});
                      },
                    ),
                  ]
              ),

              ElevatedButton(
                onPressed: () async {

                  // Create the archive
                  var fullPath = "${appDocsDir.path}/archive.zip";
                  await exportToZip(currentProjectId, fullPath, format);

                  // Try emailing it.
                  bool email = true;
                  if (email) {
                    final Email email = Email(
                      body: "Here is your esLister archive"!,
                      subject: "esLister archive",
                      // XXX No recipient, user can enter in email app
                      attachmentPaths: [ fullPath ],
                      isHTML: false,
                    );
                    var lastError = "";
                    try {
                      await FlutterEmailSender.send(email);
                    } catch (exception) {
                      print("Mail sending failed: " + exception.toString());
                    }
                  }

                  if (!mounted) {
                    return;
                  }
                  Navigator.pop(context, fullPath);
                },
                child: const Text('Export'),
              ),
            ],
          ),
        )
    );
  }
}

final pathShortenerRegExp = RegExp(".*/");

Future<void> exportToZip(int projectId, String fullPath, String format) async {
  print("Exporting project #$projectId as $format to $fullPath");
  Project proj = await localDbProvider.getProject(projectId);

  /// The image names get shortened, and the images written
  /// to "image" in the generated archive, so the archive can
  /// easily be used on the host computer.

  final archive = Archive();
  final files = [];

  for (int itemId in proj.items) {
    print('Item $itemId in project ${proj.id}');
    Item? item = await localDbProvider.getItem(itemId);
    Item? original = await localDbProvider.getItem(itemId); // item!.clone();
    for (int i = 0; i < item!.images.length; i++) {
      item.images[i] = item.images[i].replaceFirst(pathShortenerRegExp, "images/");
    }
    String generatedString;
    String fileExt;
    switch(format) {
      case 'HTML':
        generatedString = '''<html>
        <title>${item.name}</title>
        <h3>${item.name}</h3>
        <p>${item.description}</p>
        <p>Location: ${item.location}</p>
        <ul>
        ''';
        for (String imageFileName in original!.images) {
          var shortName = imageFileName.replaceAll(
              pathShortenerRegExp, "images/");
          generatedString += "<img src='$shortName' width=128px height=128px>";
        }
        generatedString += '</ul></html>';
        fileExt = ".html";
        break;
      case 'JSON':
        generatedString = json.encode(item.toMap());
        fileExt = ".json";
        break;
      default:
        throw Exception("Unknown type $format in Export code!!");
    }
    files.add(item.name);
    archive.addFile(
      ArchiveFile('${item.name}$fileExt',
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

  if (format == "HTML") {
    files.sort();
    StringBuffer index = StringBuffer(
        "<html><title>${proj.name}</title><h1>${proj.name}></h1><ul>\n");
    for (String f in files) {
      index.write('<li><a href="$f.html">$f</a></li>\n');
    }
    index.write('</ul></html>\n');
    archive.addFile(ArchiveFile("index.html", index.length, index.toString()));
  }

  // Save the ZIP archive to a file
  var encoded = ZipEncoder().encode(archive);
  final zipFile = File(fullPath);
  zipFile.writeAsBytesSync(encoded!);

}

