import 'package:eslister/provider/item_provider.dart';
import 'package:flutter/material.dart';

import 'package:eslister/main.dart' show localDbProvider;
import 'package:eslister/model/project.dart';
import 'package:provider/provider.dart';

import '../model/Item.dart';

class ProjectProvider extends ChangeNotifier {
	List<Project> _projects = [];

	ProjectProvider() {
		_init();
	}

	_init() async {
		await _loadProjects();
	}

	int get projectCount => _projects.length;

	/// Create, and notify
	Future<Project> insertProject(Project project) async {
		project.id = null; // Let DB assign on insert
		project = await localDbProvider.insertProject(project);
		_projects.add(project);
		notifyListeners();
		return project;
	}

	/// Read (no notify)
	Project getProject(int id) {
		var list =  _projects.where((itm) => itm.id == id);
		return list.first;
	}

	/// Read (no notify)
	List<Project> get projects => _projects;

	/// Update, and notify
	Future<void> updateProject(Project project) async {
		await localDbProvider.updateProject(project);
		final index = _projects.indexWhere((i) => i.id == project.id);
		_projects[index] = project;
		notifyListeners();
	}

	/// Delete, and notify
	Future<void> deleteProject(project) async {
		// Delete all items associated with the project
		for (var itemId in project.items) {
			await localDbProvider.deleteItem(itemId);
		}
		// Delete the project itself, first from the DB...
		await localDbProvider.deleteProject(project);
		// ... and then from the current list.
		_projects.removeWhere((i) => i.id == project.id!);
		notifyListeners();
	}

	_loadProjects() async {
		_projects = await localDbProvider.getAllProjects();
		notifyListeners();
	}
}
