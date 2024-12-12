import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crudapplication/utils/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskViewPage extends StatelessWidget {
  final int id;

  TaskViewPage({required this.id});

  Future<Map<String, dynamic>> fetchTaskDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url =
        Uri.parse('https://erpbeta.cloudocz.com/api/app/tasks/show/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load task details');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: AppTypography.outfitboldmainHead,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTaskDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTypography.outfitBold,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No data available',
                style: AppTypography.outfitBold,
              ),
            );
          }

          final data = snapshot.data!['data'] as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task ID: ${data['id'] ?? 'N/A'}',
                      style: AppTypography.outfitBold.copyWith(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 1, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Text(
                      'Name:',
                      style:
                          AppTypography.outfitSemiBold.copyWith(fontSize: 16),
                    ),
                    Text(
                      data['name'] ?? 'N/A',
                      style: AppTypography.outfitRegular.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Description:',
                      style:
                          AppTypography.outfitSemiBold.copyWith(fontSize: 16),
                    ),
                    Text(
                      data['description'] ?? 'N/A',
                      style: AppTypography.outfitRegular.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Percentage:',
                      style:
                          AppTypography.outfitSemiBold.copyWith(fontSize: 16),
                    ),
                    Text(
                      '${data['completed_percentage'] ?? 0}%',
                      style: AppTypography.outfitRegular.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Status:',
                      style:
                          AppTypography.outfitSemiBold.copyWith(fontSize: 16),
                    ),
                    Text(
                      data['status'] ?? 'N/A',
                      style: AppTypography.outfitExtraBold.copyWith(
                        color:
                            (data['status'] ?? '').toLowerCase() == 'incomplete'
                                ? Colors.red
                                : Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
