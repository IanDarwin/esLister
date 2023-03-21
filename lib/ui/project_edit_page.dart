import 'package:flutter/material.dart';
import 'package:eslister/model/project.dart';

/// Edit a project
class ProjectEditPage extends StatefulWidget {
  final Project project;

  ProjectEditPage({required this.project});

  @override
  _ProjectEditPageState createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  List<Project> _editedProjects = [];

  @override
  void initState() {
    super.initState();
    // Create a copy of the list of projects to edit
    //_editedProjects = List.from(widget.projects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Projects"),
      ),
      body: Column(children: [
        // Add a button to save changes
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // XXX save changes
              Navigator.pop(context, _editedProjects);
            },
            child: Text("Save Changes"),
          ),
        ),

        ListTile(
          title: TextFormField(
            initialValue: widget.project.name,
            decoration: InputDecoration(
              labelText: "Name",
            ),
            onChanged: (value) {
              setState(() {
                widget.project.name = value;
              });
            },
          ),
          subtitle: TextFormField(
            initialValue: widget.project.description ?? "",
            decoration: InputDecoration(
              labelText: "Description",
            ),
            onChanged: (value) {
              setState(() {
                widget.project.description = value.isNotEmpty ? value : null;
              });
            },
          ),
        ),
      ],
      ),
    );
  }
}

