import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/user_auth.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:flutter_swd392/repository/user_repository.dart';
import 'package:flutter_swd392/screens/emai_verify.dart';
import 'package:flutter_swd392/screens/forget_password.dart';
import 'package:flutter_swd392/screens/home_screen.dart';
import 'package:flutter_swd392/screens/register_screen.dart';

import '../services/storage.service.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _userRepository = UserRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String loginError = '';

  // Fixed initialization by removing 'late' and providing initial values
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _animationController!.forward();

    // Set system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  ///Login User Handling
  void loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      loginError = '';
    });

    final response = await _userRepository.userLogin(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (response.data == null) {
      setState(() {
        loginError = response.message ?? "Login failed";
      });

      // Show error with animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginError),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Save User Data to Local Storage
      final UserModel user = response.data!;

      UserAuth userAuth = user.toUserAuth();

      if (userAuth.token.isNotEmpty) {
        await StorageService.saveToken(userAuth.token);

        // Success animation before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Login successful')
              ],
            ),
            backgroundColor: Colors.green.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: Duration(milliseconds: 800),
            ),
          );
        });
      } else {
        setState(() {
          loginError = "Authentication failed. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient with trendy 2025 design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFE0F7FA).withOpacity(0.5),
                  Colors.white,
                  Color(0xFFE1F5FE).withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Decorative blob shapes for 2025 organic look
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.2),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade200.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Form(
                    key: _formKey,
                    // Using FadeTransition only if animation is initialized
                    child: _fadeAnimation != null ?
                    FadeTransition(
                      opacity: _fadeAnimation!,
                      child: _buildLoginForm(),
                    ) : _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extracted login form to a separate method for better readability
  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App logo
        Center(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.child_care_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Welcome Text with trendy typography
        Center(
          child: Text(
            "Welcome to Grow+",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.blue[900],
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Your child's growth journey starts here",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Email Field with modern glass-morphism design
        TextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email or username';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Email or Username",
            labelStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            hintText: "hello@example.com",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            prefixIcon: Icon(Icons.person_outline, color: Colors.blue[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            errorStyle: TextStyle(color: Colors.redAccent),
          ),
          cursorColor: Colors.blue[700],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        // Password Field with enhanced security visuals
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            hintText: "••••••••",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[700]),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            errorStyle: TextStyle(color: Colors.redAccent),
          ),
          cursorColor: Colors.blue[700],
          textInputAction: TextInputAction.done,
        ),

        const SizedBox(height: 5),

        // Modern 2025 feature: Remember me with biometric hint
        Row(
          children: [
            Theme(
              data: ThemeData(
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: Colors.blue[700],
              ),
            ),
            Text(
              "Remember me",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            Spacer(),

            // Forgot Password with modern styling
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Sign In Button with modern animation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : loginUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _isLoading ? 0 : 2,
              shadowColor: Colors.blue.withOpacity(0.4),
            ),
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2025 trendy feature: Biometric sign in
        Center(
          child: TextButton.icon(
            onPressed: () {
              // Biometric authentication would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Biometric login attempted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: Icon(Icons.fingerprint, color: Colors.blue[700], size: 22),
            label: Text(
              "Sign in with biometrics",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Social sign-in options (trending 2025 style)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google
            _buildSocialButton(
              onTap: () {},
              icon: Icons.mail_outline,
              backgroundColor: Colors.white,
              iconColor: Colors.blue[700]!,
            ),
            const SizedBox(width: 16),

            // Apple
            _buildSocialButton(
              onTap: () {},
              icon: Icons.apple,
              backgroundColor: Colors.white,
              iconColor: Colors.black,
            ),
            const SizedBox(width: 16),

            // Facebook
            _buildSocialButton(
              onTap: () {},
              icon: Icons.facebook,
              backgroundColor: Colors.white,
              iconColor: Colors.indigo,
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Sign Up Link with modern styling
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}