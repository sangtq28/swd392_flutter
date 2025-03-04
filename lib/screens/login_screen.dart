import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:flutter_swd392/repository/user_repository.dart';
import 'package:flutter_swd392/screens/pricing_page.dart';
import 'package:flutter_swd392/screens/register_screen.dart';

import '../api/api_service.dart';
import '../services/storage.service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _userRepository = UserRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String loginError = '';
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  ///Login User Handling
  void loginUser() async {
    bool stt = true;
    setState(() {
      _isLoading = true; // Show loading
      loginError = ''; // Xóa lỗi cũ trước khi login
    });
    final response = await _userRepository.userLogin(
        _emailController.text.trim(),
        _passwordController.text.trim()
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false; // Hide loading
    });
    if(response.data == null){
      setState(() {
        loginError = response.message ?? "Login failed";
      });
    } else {
      // Save User Data to Local Storage
      final UserModel user = response.data!;
      await StorageService.saveAuthData(user.toUserAuth());
      // Navigate to Pricing Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PricingPage()),
      );
    }



    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to Grow+ 👋",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Please sign-in to your account and start the adventure",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),

              // Email Field
              Text("Email or Username"),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email or username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),

              ),
              SizedBox(height: 16),


              // Password Field
              Text("Password"),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorText: loginError.isNotEmpty ? loginError : null, // Hiển thị lỗi nếu có

                ),
              ),
              SizedBox(height: 16),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to Forgot Password
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Sign In
                    _isLoading ? null : loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) :
                  const Text(
                    "Sign in",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
