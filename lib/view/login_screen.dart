import 'package:crudapplication/utils/app_typography.dart';
import 'package:crudapplication/utils/responsive.dart';
import 'package:crudapplication/view/task_listpage.dart';
import 'package:crudapplication/widgets/custom_button.dart';
import 'package:crudapplication/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = false; // To toggle password visibility

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      final response = await http.post(
        Uri.parse('https://erpbeta.cloudocz.com/api/auth/login'),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      // In the _login() method of LoginScreen
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Store the token and user details in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('user_image', responseData['image']);
        await prefs.setString('user_name', responseData['name']);
        await prefs.setString('user_position', responseData['position']);
        await prefs.setInt('user_no_of_task', responseData['no_of_task']);
        await prefs.setInt('user_percentage', responseData['percentage']);

        // Navigate to TaskListPage
     Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => TaskListPage(),
  ),
  (Route<dynamic> route) => false,
);
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials';
        });
        CustomSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          label: 'Login Failed: Invalid credentials',
          bgColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.hp(10)),
                Text(
                  'Welcome Back!',
                  style: AppTypography.outfitboldmainHead,
                ),
                SizedBox(height: responsive.hp(2)),
                Text(
                  'Please sign in to your account',
                  style: AppTypography.outfitRegular.copyWith(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: responsive.hp(5)),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTypography.outfitboldsubHead,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: responsive.hp(2)),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTypography.outfitboldsubHead,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword; // Toggle visibility
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: responsive.hp(2)),
                Text(
                  _errorMessage,
                  style: AppTypography.outfitRegular.copyWith(
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: responsive.hp(4)),
                CustomButton(
                  buttonName: 'Login',
                  onTap: _login,
                  buttonColor: Colors.blue,
                  height: responsive.hp(6),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
