import 'package:flutter/material.dart';
import 'package:crudapplication/model/task_model.dart';
import 'package:crudapplication/utils/app_typography.dart';

class TaskViewPage extends StatelessWidget {
  final List<Datum> tasks;

  TaskViewPage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task View', style: AppTypography.outfitboldmainHead),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('No tasks found', style: AppTypography.outfitRegular),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(task.name, style: AppTypography.outfitMedium),
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
                          style: AppTypography.outfitLight.copyWith(color: Colors.grey),
                        ),
                        Text(
                          'Status: ${task.status}',
                          style: AppTypography.outfitLight.copyWith(color: Colors.blue),
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
