import 'package:crudapplication/model/admin_model.dart';
import 'package:crudapplication/model/server_model.dart';
import 'package:crudapplication/model/task_model.dart';
import 'package:crudapplication/utils/app_typography.dart';
import 'package:crudapplication/view/profile_screen.dart';
import 'package:crudapplication/view/task_view.dart';
import 'package:crudapplication/viewmodel/task_viewmodel.dart';
import 'package:crudapplication/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
            CustomButton(
              buttonName: 'Cancel',
              onTap: () => Navigator.pop(context),
              buttonColor: Colors.red, // You can choose a suitable color
              height: 40,
              width: 100,
            ),
            CustomButton(
              buttonName: 'Add',
              onTap: () {
                Provider.of<TaskViewModel>(context, listen: false)
                    .addTask(
                      nameController.text,
                      descriptionController.text,
                      deadlineController.text,
                      context, // Pass the context here
                    )
                    .then((_) => Navigator.pop(context));
              },
              buttonColor: Colors.green, // You can choose a suitable color
              height: 40,
              width: 100,
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
            CustomButton(
              buttonName: 'Cancel',
              onTap: () => Navigator.pop(context),
              buttonColor: Colors.red, // You can choose a suitable color
              height: 40,
              width: 100,
            ),
            CustomButton(
              buttonName: 'Update',
              onTap: () {
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
              buttonColor: Colors.green,
              height: 40,
              width: 100,
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
          title:
              const Text('Task List', style: AppTypography.outfitboldmainHead),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ]),
      body: taskViewModel.isLoading
          ? _buildSkeletonLoader()
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
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaskViewPage(
                                        id: task.id,
                                      )));
                        },
                        child: Card(
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
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green), // Changed to green
                                  onPressed: () => _showEditTaskDialog(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red), // Changed to red
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        context, task.id);
                                  },
                                ),
                              ],
                            ),
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

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Number of skeleton items to show
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Container(
                height: 16,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
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
          CustomButton(
            buttonName: 'Cancel',
            onTap: () => Navigator.pop(dialogContext),
            buttonColor: Colors.red, // You can choose a suitable color
            height: 40,
            width: 100,
          ),
          CustomButton(
            buttonName: 'Delete',
            onTap: () {
              Navigator.pop(dialogContext); // Close the dialog
              // Use the `context` of `TaskListPage` instead of the dialog's context
              Provider.of<TaskViewModel>(context, listen: false)
                  .deleteTask(taskId, context);
            },
            buttonColor: Colors.green,
            height: 40,
            width: 100,
          ),
        ],
      );
    },
  );
}
