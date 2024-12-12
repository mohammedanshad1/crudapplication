import 'package:crudapplication/model/admin_model.dart';
import 'package:crudapplication/model/server_model.dart';
import 'package:crudapplication/model/task_model.dart';
import 'package:crudapplication/utils/app_typography.dart';
import 'package:crudapplication/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TaskListPage extends StatefulWidget {
  final AdminModel? adminModel; // Add this
  final ServerModel? serverModel; // Add this

  TaskListPage({this.adminModel, this.serverModel}); // Update the constructor

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<TaskModel> _taskModelFuture;
  List<Datum> _tasks = [];

  @override
  void initState() {
    super.initState();
    _taskModelFuture = fetchTasks();
  }

  Future<TaskModel> fetchTasks() async {
    final response =
        await http.get(Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks'));
    if (response.statusCode == 200) {
      return TaskModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _taskModelFuture = fetchTasks();
    });
  }

 Future<void> _addTask(String name, String description, String deadline) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    CustomSnackBar.show(
      context,
      snackBarType: SnackBarType.fail,
      label: 'You are not logged in. Please log in again.',
      bgColor: Colors.red,
    );
    return;
  }

  final response = await http.post(
    Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/store'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Include the token here
    },
    body: json.encode({
      "name": name,
      "description": description,
      "deadline": deadline,
    }),
  );

  final responseData = json.decode(response.body);

  if (response.statusCode == 200 && responseData['error'] == false) {
    CustomSnackBar.show(
      context,
      snackBarType: SnackBarType.success,
      label: 'Task created successfully',
      bgColor: Colors.green,
    );
    _refreshTasks();
  } else {
    print(responseData); // Print the response for debugging
    CustomSnackBar.show(
      context,
      snackBarType: SnackBarType.fail,
      label: 'Failed to create task: ${responseData['message']}',
      bgColor: Colors.red,
    );
  }
}

  Future<void> _updateTask(
      int id, String name, String description, String deadline) async {
    final response = await http.put(
      Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "description": description,
        "deadline": deadline,
      }),
    );

    if (response.statusCode == 200) {
      CustomSnackBar.show(
        context,
        snackBarType: SnackBarType.success,
        label: 'Task updated successfully',
        bgColor: Colors.green,
      );
      _refreshTasks();
    } else {
      CustomSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        label: 'Failed to update task',
        bgColor: Colors.red,
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/destroy/$id'),
    );

    if (response.statusCode == 200) {
      CustomSnackBar.show(
        context,
        snackBarType: SnackBarType.success,
        label: 'Task deleted successfully',
        bgColor: Colors.green,
      );
      _refreshTasks();
    } else {
      CustomSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        label: 'Failed to delete task',
        bgColor: Colors.red,
      );
    }
  }

  void _showAddTaskDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task', style: AppTypography.outfitboldmainHead),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.outfitRegular),
            ),
            TextButton(
              onPressed: () {
                _addTask(
                  nameController.text,
                  descriptionController.text,
                  deadlineController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Add', style: AppTypography.outfitBold),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Datum task) {
    final TextEditingController nameController =
        TextEditingController(text: task.name);
    final TextEditingController descriptionController =
        TextEditingController(text: task.description.toString());
    final TextEditingController deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task', style: AppTypography.outfitboldmainHead),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: AppTypography.outfitLight,
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: AppTypography.outfitLight,
                ),
              ),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  labelStyle: AppTypography.outfitLight,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.outfitRegular),
            ),
            TextButton(
              onPressed: () {
                _updateTask(
                  task.id,
                  nameController.text,
                  descriptionController.text,
                  deadlineController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Update', style: AppTypography.outfitBold),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List', style: AppTypography.outfitboldmainHead),
      ),
      body: FutureBuilder<TaskModel>(
        future: _taskModelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return Center(
                child:
                    Text('No tasks found', style: AppTypography.outfitRegular));
          } else {
            _tasks = snapshot.data!.data;
            return RefreshIndicator(
              onRefresh: _refreshTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(task.name, style: AppTypography.outfitMedium),
                    subtitle: Text(task.description.toString(),
                        style: AppTypography.outfitRegular),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditTaskDialog(task),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
