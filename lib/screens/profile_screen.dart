import 'dart:convert';
import 'dart:io';
import 'package:flutter_swd392/screens/payment_history.dart';
import 'package:flutter_swd392/services/storage.service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/all_children.dart';
import 'package:flutter_swd392/screens/change_password.dart';
import 'package:flutter_swd392/screens/login_screen.dart';
import 'package:flutter_swd392/screens/update_profile_screen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../repository/user_repository.dart';
import 'current_package_screen.dart';
import 'dart:ui';
import 'package:http_parser/http_parser.dart'; // Add this import

class UserController extends GetxController {
  final isLoading = false.obs;
  final isEditing = false.obs;
  final userProfile = {}.obs;

  // Use late init to avoid unnecessary null checks
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController avatarController;

// Add these new properties
  final ImagePicker _picker = ImagePicker();
  final selectedImage = Rxn<File>();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        await uploadAvatar();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> uploadAvatar() async {
    final userAuth = await StorageService.getAuthData();
    final token = userAuth?.token;
    if(token == null) {
      Get.snackbar('Error', 'Failed to upload avatar: Token is null');
      return;
    }
    if (selectedImage.value == null) return;

    try {
      isLoading.value = true;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://swd392-backend-fptu.growplus.hungngblog.com/api/Users/UploadAvatar'),
      );

      request.headers.addAll({
        'accept': 'text/plain',
        'Authorization': token,
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        selectedImage.value!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200 && jsonResponse['status'] == 'successful') {
        // Update using direct assignment
        userProfile['avatar'] = jsonResponse['data']['url'];
        userProfile.refresh(); // Notify listeners of the change
        avatarController.text = jsonResponse['data']['url'];
        Get.snackbar('Success', 'Avatar uploaded successfully');
      } else {
        throw Exception('Upload failed: ${jsonResponse['message']}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload avatar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers here to avoid memory leaks
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    avatarController = TextEditingController();
    fetchUserProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    avatarController.dispose();
    super.onClose();
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final data = await UserRepository().getUserProfile();
      if (data != null) {
        userProfile.value = data.toJson();
        _setControllerValues(
            data.fullName,
            data.email,
            data.phoneNumber,
            data.avatar
        );
      } else {
        _setDefaultValues();
        Get.snackbar(
          'Error',
          'Failed to load user profile: Data is null',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    } catch (e) {
      _setDefaultValues();
      Get.snackbar(
        'Error',
        'Failed to load user profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _setControllerValues(String? name, String? email, String? phone,
      String? avatar) {
    fullNameController.text = name ?? 'Truong Sanggg';
    emailController.text = email ?? 'santruong2003.work@gmail.com';
    phoneController.text = phone ?? "123456789";
    avatarController.text = avatar ?? 'https://via.placeholder.com/140';
  }

  void _setDefaultValues() {
    _setControllerValues(
        'Truong Sanggg',
        'santruong2003.work@gmail.com',
        '123456789',
        'https://via.placeholder.com/140'
    );
  }
}

class UserScreen extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  UserScreen({super.key});


  @override
  Widget build(BuildContext context) {
    // Use Theme.of and MediaQuery.of only once for better performance
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    // 2025 trends: Vibrant gradients with a touch of glassmorphism and minimalism
    // More vibrant gradient for 2025 (purple to electric blue with a hint of cyan)
    final primaryGradient = LinearGradient(
      colors: [
        Color(0xFF8A2BE2), // Vibrant Purple
        Color(0xFF4169E1), // Royal Blue
        Color(0xFF00BFFF), // Deep Sky Blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Glassmorphism color schemes for 2025
    final glassColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.65);
    final glassBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.2);
    final glassShadow = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.08);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Color(0xFF121225) : Color(0xFFF9FAFC),
      appBar: _buildAppBar(context, isDark, glassColor, glassBorder),
      body: Obx(
            () => controller.isLoading.value
            ? _buildLoadingIndicator()
            : SafeArea(
          maintainBottomViewPadding: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modernized Header with dynamic mesh gradient
                _buildProfileHeader(
                  context,
                  size,
                  primaryGradient,
                ),

                // Settings section with glassmorphism cards
                _buildSettingsSection(
                    context,
                    isDark,
                    glassColor,
                    glassBorder,
                    glassShadow
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extracted methods for better organization and reusability

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A2BE2)),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, Color glassColor, Color glassBorder) {
    return AppBar(
      backgroundColor: Colors.blue[700],
      elevation: 0,
      toolbarHeight: 50, // Reduced height for a smaller app bar
      title: Text(
        "Profile",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18, // Smaller font size
          letterSpacing: 0.3,
        ),
      ),
      titleSpacing: 0, // Reduce default spacing
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0), // Smaller padding
          child: IconButton(
            padding: EdgeInsets.zero, // Remove default padding
            constraints: BoxConstraints(), // Remove constraints
            onPressed: () {
              // Toggle theme
              Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark
              );
            },
            icon: Container(
              padding: EdgeInsets.all(6), // Smaller padding
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon,
                color: isDark ? Colors.white : Color(0xFF8A2BE2),
                size: 16, // Smaller icon
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, Size size, LinearGradient gradient) {
    // Fixed height to prevent overflow issues
    final double headerHeight = 200; // Slightly reduced height
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity, // This ensures full width
      constraints: BoxConstraints(minHeight: headerHeight),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Simplified avatar with clean styling
            _buildSimplifiedAvatar(),

            SizedBox(height: 10),

            // Name with cleaner styling
            Text(
              controller.fullNameController.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF333333),
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 4),

            // Email with cleaner styling
            Text(
              controller.emailController.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                letterSpacing: 0.3,
              ),
            ),

            SizedBox(height: 12),

            // Simplified Edit Profile Button
            _buildSimplifiedEditButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar with border
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: controller.avatarController.text.isNotEmpty
                ? Image.network(
              controller.userProfile['avatar'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
                : Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),

        // Edit icon positioned at the bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  )
                ]
            ),
            child: Obx(() {
              final controller = Get.find<UserController>();
              return IconButton(
                onPressed: controller.isLoading.value ? null : () {
                  controller.pickImage();
                },
                icon: controller.isLoading.value
                    ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A2BE2)),
                  ),
                )
                    : Icon(
                  LineAwesomeIcons.pencil_alt_solid,
                  color: Color(0xFF8A2BE2),
                  size: 14,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedEditButton() {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: () => Get.to(() => EditProfileScreen()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LineAwesomeIcons.edit, size: 12,  color: Colors.white70,),
            SizedBox(width: 5),
            Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark, Color glassColor, Color glassBorder, Color glassShadow) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),

          // Section title with modernized styling
          _buildSectionTitle(
            "SETTINGS",
            isDark,
          ),

          SizedBox(height: 12),

          // Menu items with enhanced 2025 styling
          ProfileMenuWidget2025(
            title: "Children",
            subtitle: "Manage your children's profiles",
            icon: LineAwesomeIcons.baby_solid,
            iconBgColor: Color(0xFFE0F7FA),
            iconColor: Color(0xFF0097A7),
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllChildrenScreen()),
              );
            },
            isDark: isDark,
            glassColor: glassColor,
            glassBorder: glassBorder,
            glassShadow: glassShadow,
          ),

          ProfileMenuWidget2025(
            title: "Billing Details",
            subtitle: "Manage your payment methods",
            icon: LineAwesomeIcons.wallet_solid,
            iconBgColor: Color(0xFFFFF8E1),
            iconColor: Color(0xFFFF9800),
            onPress: () {
              // Navigate to billing details screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
              );
            },
            isDark: isDark,
            glassColor: glassColor,
            glassBorder: glassBorder,
            glassShadow: glassShadow,
          ),

          ProfileMenuWidget2025(
            title: "Membership Package",
            subtitle: "View or upgrade your current plan",
            icon: LineAwesomeIcons.sketch,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF1976D2),
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurrentPackageScreen()),
              );
            },
            isDark: isDark,
            glassColor: glassColor,
            glassBorder: glassBorder,
            glassShadow: glassShadow,
          ),

          _buildDivider(isDark),

          _buildSectionTitle(
            "ACCOUNT",
            isDark,
          ),

          SizedBox(height: 12),

          ProfileMenuWidget2025(
            title: "Change Password",
            subtitle: "Update your password regularly",
            icon: LineAwesomeIcons.lock_solid,
            iconBgColor: Color(0xFFE1F5FE),
            iconColor: Color(0xFF0288D1),
            onPress: () {
              Get.to(() => ResetPasswordScreen());
            },
            isDark: isDark,
            glassColor: glassColor,
            glassBorder: glassBorder,
            glassShadow: glassShadow,
          ),

          ProfileMenuWidget2025(
            title: "Logout",
            subtitle: "Sign out of your account",
            icon: LineAwesomeIcons.sign_out_alt_solid,
            iconBgColor: Color(0xFFFFEBEE),
            iconColor: Color(0xFFE53935),
            showTrailing: false,
            onPress: () {
              _showLogoutDialog(context, isDark);
            },
            isDark: isDark,
            glassColor: glassColor,
            glassBorder: glassBorder,
            glassShadow: glassShadow,
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : Colors.black54,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: isDark ? Colors.white10 : Colors.black12,
        thickness: 1,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    final dialogBackgroundColor = isDark ? Color(0xFF1E1E2E) : Colors.white;

    Get.defaultDialog(
      backgroundColor: dialogBackgroundColor,
      title: "Logout",
      titleStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      radius: 16,
      contentPadding: EdgeInsets.all(20),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          "Are you sure you want to logout?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 15,
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => AuthenticationRepository.instance.logout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE53935),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
        child: Text(
          "Yes",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF8A2BE2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Color(0xFF8A2BE2)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          "No",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget2025 extends StatelessWidget {
  const ProfileMenuWidget2025({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPress,
    required this.isDark,
    required this.glassColor,
    required this.glassBorder,
    required this.glassShadow,
    this.showTrailing = true,
    this.iconBgColor = const Color(0xFFF5F3FF),
    this.iconColor = const Color(0xFF8A2BE2),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPress;
  final bool showTrailing;
  final Color iconBgColor;
  final Color iconColor;
  final bool isDark;
  final Color glassColor;
  final Color glassBorder;
  final Color glassShadow;

  @override
  Widget build(BuildContext context) {
    // 2025 UI trend: Glassmorphism with subtle backdrop blur
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassBorder),
            boxShadow: [
              BoxShadow(
                color: glassShadow,
                blurRadius: 12,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: isDark
                  ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
                  : ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: iconColor.withOpacity(0.1),
                  highlightColor: iconColor.withOpacity(0.05),
                  onTap: onPress,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Row(
                      children: [
                        // Modern icon with gradient background
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: iconColor.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        SizedBox(width: 12),
                        // Text content with improved typography
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Modernized trailing indicator
                        if (showTrailing)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Icon(
                              LineAwesomeIcons.angle_right_solid,
                              size: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticationRepository {
  static final AuthenticationRepository instance = AuthenticationRepository();
  void logout() {
    Get.offAll(() =>  SignInScreen());
  }
}