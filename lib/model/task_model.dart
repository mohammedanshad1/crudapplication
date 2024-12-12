class TaskModel {
  final int totalTasks;
  final int pendingTasks;
  final List<Datum> data;

  TaskModel({
    required this.totalTasks,
    required this.pendingTasks,
    required this.data,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      totalTasks: json['total_tasks'],
      pendingTasks: json['pending_tasks'],
      data: List<Datum>.from(
        json['data'].map((x) => Datum.fromJson(x)),
      ),
    );
  }
}

class Datum {
  final int id;
  final String name;
  final String description;
  final int percentage;
  final String status;

  Datum({
    required this.id,
    required this.name,
    required this.description,
    required this.percentage,
    required this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      percentage: json['percentage'],
      status: json['status'],
    );
  }
}