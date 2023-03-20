import 'package:flutter/material.dart';
import 'package:eslister/model/project.dart';

/// Edit a project
class EditProjectsPage extends StatefulWidget {
  final List<Project> projects;

  EditProjectsPage({required this.projects});

  @override
  _EditProjectsPageState createState() => _EditProjectsPageState();
}

class _EditProjectsPageState extends State<EditProjectsPage> {
  List<Project> _editedProjects = [];

  @override
  void initState() {
    super.initState();
    // Create a copy of the list of projects to edit
    _editedProjects = List.from(widget.projects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Projects"),
      ),
      body: ListView.builder(
        itemCount: _editedProjects.length + 1,
        itemBuilder: (context, index) {
          if (index == _editedProjects.length) {
            // Add a button to save changes
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Replace this with your own code to save changes
                  Navigator.pop(context, _editedProjects);
                },
                child: Text("Save Changes"),
              ),
            );
          } else {
            final project = _editedProjects[index];
            return ListTile(
              title: TextFormField(
                initialValue: project.name,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (value) {
                  setState(() {
                    project.name = value;
                  });
                },
              ),
              subtitle: TextFormField(
                initialValue: project.description ?? "",
                decoration: InputDecoration(
                  labelText: "Description",
                ),
                onChanged: (value) {
                  setState(() {
                    project.description = value.isNotEmpty ? value : null;
                  });
                },
              ),
            );
          }
        },
      ),
    );
  }
}

