// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
    int totalTasks;
    int pendingTasks;
    List<Datum> data;

    TaskModel({
        required this.totalTasks,
        required this.pendingTasks,
        required this.data,
    });

    factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        totalTasks: json["total_tasks"],
        pendingTasks: json["pending_tasks"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total_tasks": totalTasks,
        "pending_tasks": pendingTasks,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    String name;
    Description description;
    int percentage;
    Status status;

    Datum({
        required this.id,
        required this.name,
        required this.description,
        required this.percentage,
        required this.status,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        description: descriptionValues.map[json["description"]]!,
        percentage: json["percentage"],
        status: statusValues.map[json["status"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": descriptionValues.reverse[description],
        "percentage": percentage,
        "status": statusValues.reverse[status],
    };
}

enum Description {
    EMPTY,
    HELLO_HAI,
    P_WEB_APPLICATION_DEVELOPMENT_P
}

final descriptionValues = EnumValues({
    "": Description.EMPTY,
    "Hello hai": Description.HELLO_HAI,
    "<p>Web Application Development</p>": Description.P_WEB_APPLICATION_DEVELOPMENT_P
});

enum Status {
    INCOMPLETE
}

final statusValues = EnumValues({
    "incomplete": Status.INCOMPLETE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
