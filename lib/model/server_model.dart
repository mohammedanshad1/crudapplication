import 'dart:convert';

ServerModel serverModelFromJson(String str) => ServerModel.fromJson(json.decode(str));

String serverModelToJson(ServerModel data) => json.encode(data.toJson());

class ServerModel {
  String token;
  String image;
  String name;
  String position;
  int noOfTask;
  int percentage;

  ServerModel({
    required this.token,
    required this.image,
    required this.name,
    required this.position,
    required this.noOfTask,
    required this.percentage,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) => ServerModel(
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