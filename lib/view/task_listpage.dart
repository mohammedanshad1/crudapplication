import 'package:crudapplication/model/admin_model.dart';
import 'package:crudapplication/model/server_model.dart';
import 'package:crudapplication/model/task_model.dart';
import 'package:crudapplication/utils/app_typography.dart';
import 'package:crudapplication/viewmodel/task_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskListPage extends StatefulWidget {
  final AdminModel? adminModel;
  final ServerModel? serverModel;

  TaskListPage({this.adminModel, this.serverModel});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks();
    });
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Add Task', style: AppTypography.outfitboldmainHead),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: AppTypography.outfitRegular),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TaskViewModel>(context, listen: false)
                    .addTask(
                      nameController.text,
                      descriptionController.text,
                      deadlineController.text,
                      context, // Pass the context here
                    )
                    .then((_) => Navigator.pop(context));
              },
              child: const Text('Add', style: AppTypography.outfitBold),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Datum task) {
    final nameController = TextEditingController(text: task.name);
    final descriptionController =
        TextEditingController(text: task.description.toString());
    final deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Edit Task', style: AppTypography.outfitboldmainHead),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  labelStyle: AppTypography.outfitboldsubHead,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: AppTypography.outfitRegular),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    deadlineController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }
                Provider.of<TaskViewModel>(context, listen: false)
                    .updateTask(
                      task.id,
                      nameController.text,
                      descriptionController.text,
                      deadlineController.text,
                      context, // Pass the context here
                    )
                    .then((_) => Navigator.pop(context));
              },
              child: const Text('Update', style: AppTypography.outfitBold),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List', style: AppTypography.outfitboldmainHead),
      ),
      body: taskViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskViewModel.tasks.isEmpty
              ? const Center(
                  child: Text('No tasks found',
                      style: AppTypography.outfitRegular))
              : RefreshIndicator(
                  onRefresh: () => taskViewModel.fetchTasks(),
                  child: ListView.builder(
                    itemCount: taskViewModel.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskViewModel.tasks[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(task.name,
                              style: AppTypography.outfitMedium),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                task.description.toString(),
                                style: AppTypography.outfitRegular,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Percentage: ${task.percentage}%',
                                style: AppTypography.outfitLight
                                    .copyWith(color: Colors.grey),
                              ),
                              Text(
                                'Status: ${task.status}',
                                style: AppTypography.outfitLight
                                    .copyWith(color: Colors.blue),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditTaskDialog(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, task.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context, int taskId) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title:
            const Text('Delete Task', style: AppTypography.outfitboldmainHead),
        content: const Text('Are you sure you want to delete this task?',
            style: AppTypography.outfitRegular),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: AppTypography.outfitRegular),
          ),
          TextButton(
            onPressed: () {
              print(taskId);
              Navigator.pop(dialogContext); // Close the dialog
              // Use the `context` of `TaskListPage` instead of the dialog's context
              Provider.of<TaskViewModel>(context, listen: false)
                  .deleteTask(taskId, context);
            },
            child: const Text('Delete', style: AppTypography.outfitBold),
          ),
        ],
      );
    },
  );
}
