import 'package:flutter/material.dart';
import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/repository/user_repository.dart';
import 'package:flutter_swd392/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userRepository = UserRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreeTerms = false;
  bool _isLoading = false;
  String registerError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  /// Register API Call
  void register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email and password cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final response = await _userRepository.userSignUp(email, password);
   if(!mounted) return;
   setState(() {
      _isLoading = false;
   });
   if(response == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response),
          backgroundColor: Colors.red,
        ),
      );
   }

  } // end call RegisterCallAPI




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Adventure starts here 🚀",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Make your app management easy and fun!",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Email Field
              const Text("Email"),
              const SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password Field
              const Text("Password"),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Confirm Password Field
              const Text("Confirm Password"),
              const SizedBox(height: 5),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = value!;
                      });
                    },
                  ),
                  const Text("I agree to "),
                  GestureDetector(
                    onTap: () {
                      // Open privacy policy link
                    },
                    child: const Text(
                      "privacy policy & terms",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _isLoading ? null : register(); //Disable button when loading
                    // Handle sign-up logic
                  },
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) :
                  const Text(
                    "Sign up",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Already have an account? Create an account
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to login screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Already have an account? "),
                        Text(
                          "Sign in",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
