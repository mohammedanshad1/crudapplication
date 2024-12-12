import 'package:crudapplication/view/login_screen.dart';
import 'package:crudapplication/utils/app_typography.dart';
import 'package:crudapplication/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userPosition = '';
  String _userImage = '';
  int _noOfTasks = 0;
  int _percentage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userPosition = prefs.getString('user_position') ?? 'Position';
      _userImage = prefs.getString('user_image') ?? '';
      _noOfTasks = prefs.getInt('user_no_of_task') ?? 0;
      _percentage = prefs.getInt('user_percentage') ?? 0;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: AppTypography.outfitboldmainHead),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage:
                    _userImage.isNotEmpty ? NetworkImage(_userImage) : null,
                child: _userImage.isEmpty
                    ? const Icon(Icons.person, size: 80)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                _userName,
                style: AppTypography.outfitboldmainHead.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                _userPosition,
                style: AppTypography.outfitRegular.copyWith(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 30),
              CustomButton(
                buttonName: 'Logout',
                onTap: _logout,
                buttonColor: Colors.red,
                height: 50,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn('Tasks', _noOfTasks.toString()),
            _buildInfoColumn('Completed', '$_percentage%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.outfitboldmainHead.copyWith(
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: AppTypography.outfitRegular.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
