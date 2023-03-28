import 'dart:ui';

import 'package:eslister/main.dart';
import 'package:eslister/provider/project_provider.dart';
import 'package:eslister/ui/project_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:eslister/model/project.dart';
import 'package:provider/provider.dart';

/// The list of Projects that the user can work on.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  ProjectListPageState createState() => ProjectListPageState();
}

class ProjectListPageState extends State<ProjectListPage> {
  int _selectedProjectId = -1;

  @override
  Widget build(BuildContext context) {
    var projects = context.watch<ProjectProvider>().projects;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects List"),
      ),
      body: projects.isEmpty ?
        const Center(child: Text("No projects yet")) :
        ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project.name),
                  subtitle: project.description != null ? Text(project.description!) : null,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (ProjectEditPage(project: project))));
                    setState(() {
                      _selectedProjectId = project.id!;
                    });
                  },
                  selected: project.id == _selectedProjectId,
                );
              },
            ),
      floatingActionButton: _selectedProjectId >= 0
          ? FloatingActionButton(
              onPressed: () {
                // Replace this with your own code to handle the selected project
                print("Selected project with id $_selectedProjectId");
              },
              child: Icon(Icons.check),
            )
          : null,
    );
  }
}

