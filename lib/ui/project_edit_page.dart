import 'package:eslister/main.dart';
import 'package:flutter/material.dart';
import 'package:eslister/model/project.dart';
import 'package:provider/provider.dart';

import '../provider/project_provider.dart';

/// Edit a project
class ProjectEditPage extends StatefulWidget {
  final Project project;

  ProjectEditPage({super.key, required this.project});

  @override
  ProjectEditPageState createState() => ProjectEditPageState();
}

class ProjectEditPageState extends State<ProjectEditPage> {
  final List<Project> _editedProjects = [];

  @override
  Widget build(BuildContext context) {
	var provider = context.watch<ProjectProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Projects"),
      ),
      body: Column(children: [
        // Add a button to save changes
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              provider.updateProject(widget.project);
              Navigator.pop(context, _editedProjects);
            },
            child: Text("Save Changes"),
          ),
        ),

        Column(children: [

          Text('Project Id ${widget.project.id}'),
          TextFormField(
            initialValue: widget.project.name,
            decoration: const InputDecoration(
              labelText: "Name",
            ),
            onChanged: (value) {
              setState(() {
                widget.project.name = value;
              });
            },
            onSaved: (value) => widget.project.name = value!,
          ),
          TextFormField(
            initialValue: widget.project.description ?? "",
            decoration: const InputDecoration(
              labelText: "Description",
            ),
            onChanged: (value) {
              setState(() {
                widget.project.description = value.isNotEmpty ? value : null;
              });
            },
            onSaved: (value) => widget.project.description = value!,
          ),
          ]
        ),
      ],
      ),
    );
  }
}

