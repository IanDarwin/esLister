import 'package:eslister/provider/project_provider.dart';
import 'package:eslister/ui/project_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/project.dart';

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
              trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        // must tap a button to dismiss
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text("Really Delete ${project.name}?"),
                              content: Text(
                                  "Are you sure you want to permanently delete ${project.name} and all its items?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    var provider = Provider.of<ProjectProvider>(context, listen:false);
                                    provider.deleteProject(project);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Really delete"),
                                ),
                              ]
                          );
                        });
                  }
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddDialog(context);
          },
        child: Icon(Icons.add),
      ),
    );
  }

  // The Project object is simple enough to create right here
  void _showAddDialog(BuildContext context) {
    var nameController = TextEditingController();
    var descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                nameController.clear();
                descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Project project = Project(
                  id: 0,
                  name: nameController.text,
                  description: descriptionController.text,
                );
                Provider.of<ProjectProvider>(context, listen: false).insertProject(project);
                nameController.clear();
                descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

