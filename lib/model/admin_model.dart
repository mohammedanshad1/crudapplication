import 'dart:convert';

AdminModel adminModelFromJson(String str) => AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  String token;
  String image;
  String name;
  String position;
  int noOfTask;
  int percentage;

  AdminModel({
    required this.token,
    required this.image,
    required this.name,
    required this.position,
    required this.noOfTask,
    required this.percentage,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
    token: json["token"],
    image: json["image"],
    name: json["name"],
    position: json["position"],
    noOfTask: json["no_of_task"],
    percentage: json["percentage"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "image": image,
    "name": name,
    "position": position,
    "no_of_task": noOfTask,
    "percentage": percentage,
  };
}