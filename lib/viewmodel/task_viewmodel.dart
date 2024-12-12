import 'dart:convert';
import 'package:crudapplication/model/task_model.dart';
import 'package:crudapplication/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskViewModel extends ChangeNotifier {
  List<Datum> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Datum> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _errorMessage = 'You are not logged in. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'Response Body: ${response.body}'); // Debugging: Print the response body

      if (response.statusCode == 200) {
        final taskModel = TaskModel.fromJson(json.decode(response.body));
        _tasks = taskModel.data;
        print(
            'Tasks Length: ${_tasks.length}'); // Debugging: Print the number of tasks
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load tasks';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String name, String description, String deadline,
      BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      _errorMessage = 'You are not logged in. Please log in again.';
      notifyListeners();
      return;
    }

    final response = await http.post(
      Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/store'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "name": name,
        "description": description,
        "deadline": deadline,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['error'] == false) {
      _errorMessage = 'Task created successfully';
      await fetchTasks(); // Refresh the task list

      // Show custom snackbar for success
      _showCustomSnackBar(context, 'Task added successfully',
          SnackBarType.success, Colors.green);
    } else {
      _errorMessage = 'Failed to create task: ${responseData['message']}';

      // Show custom snackbar for error
      _showCustomSnackBar(
          context, 'Failed to add task', SnackBarType.fail, Colors.red);
    }

    notifyListeners();
  }

  Future<void> updateTask(int id, String name, String description,
      String deadline, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      _errorMessage = 'You are not logged in. Please log in again.';
      notifyListeners();
      return;
    }

    print('Token: $token'); // Debugging: Print the token
    print('Updating Task ID: $id'); // Debugging: Print the task ID

    final response = await http.post(
      Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "name": name,
        "description": description,
        "deadline": deadline,
      }),
    );
    print(response.statusCode);
    print(
        'Update Response Body: ${response.body}'); // Debugging: Print the response body

    try {
      final responseData =
          response.body.isNotEmpty ? json.decode(response.body) : {};

      if (response.statusCode == 200 && responseData['error'] == false) {
        _errorMessage = 'Task updated successfully';
        await fetchTasks(); // Refresh the task list

        // Show custom snackbar for success
        _showCustomSnackBar(context, 'Task updated successfully',
            SnackBarType.success, Colors.green);
      } else {
        _errorMessage = 'Failed to update task: ${responseData['message']}';

        // Show custom snackbar for error
        _showCustomSnackBar(
            context, 'Failed to update task', SnackBarType.fail, Colors.red);
      }
    } catch (e) {
      _errorMessage = 'Error parsing API response: $e';
      _showCustomSnackBar(
          context, 'Failed to update task', SnackBarType.fail, Colors.red);
    }

    notifyListeners();
  }

Future<void> deleteTask(int id, BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      _errorMessage = 'You are not logged in. Please log in again.';
      notifyListeners();
      return;
    }

    final response = await http.post(
      Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/destroy/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Handle empty or invalid JSON response
    dynamic responseData;
    try {
      responseData = response.body.isNotEmpty ? json.decode(response.body) : null;
    } catch (e) {
      responseData = null;
    }

    if (response.statusCode == 200 &&
        (responseData == null || responseData['error'] == false)) {
      _errorMessage = 'Task deleted successfully';
      await fetchTasks(); // Refresh the task list

      // Show custom snackbar for success
      _showCustomSnackBar(context, 'Task deleted successfully',
          SnackBarType.success, Colors.green);
    } else {
      _errorMessage = responseData != null
          ? 'Failed to delete task: ${responseData['message']}'
          : 'Failed to delete task: Invalid response';

      // Show custom snackbar for error
      _showCustomSnackBar(
          context, 'Failed to delete task', SnackBarType.fail, Colors.red);
    }
  } catch (e) {
    // Handle any unexpected errors
    _errorMessage = 'An unexpected error occurred: $e';

    // Show custom snackbar for error
    _showCustomSnackBar(
        context, 'Failed to delete task', SnackBarType.fail, Colors.red);
  } finally {
    notifyListeners();
  }
}


  void _showCustomSnackBar(BuildContext context, String message,
      SnackBarType snackBarType, Color bgColor) {
    CustomSnackBar.show(
      context,
      snackBarType: snackBarType,
      label: message,
      bgColor: bgColor,
    );
  }
}
