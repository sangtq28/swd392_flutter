import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/user_auth.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
        ),
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            /// Phần trên
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// -- IMAGE
                  Stack(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const Image(
                            image: AssetImage("assets/images/profile.png"),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue,
                          ),
                          child: const Icon(
                            LineAwesomeIcons.pencil_alt_solid,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text("John Doe", style: Theme.of(context).textTheme.headlineMedium),
                  Text("john.doe@example.com", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 30),

                  /// -- BUTTON
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const UpdateProfileScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),

            /// Danh sách menu
            Expanded(
              child: ListView(

                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  ProfileMenuWidget(title: "Settings", icon: LineAwesomeIcons.sketch, onPress: () {}),
                  ProfileMenuWidget(title: "Billing Details", icon: LineAwesomeIcons.wallet_solid, onPress: () {}),
                  ProfileMenuWidget(title: "User Management", icon: LineAwesomeIcons.user, onPress: () {}),
                  const Divider(),
                  ProfileMenuWidget(title: "Information", icon: LineAwesomeIcons.info_solid, onPress: () {}),
                  ProfileMenuWidget(
                    title: "Logout",
                    icon: LineAwesomeIcons.sign_out_alt_solid,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () {
                      Get.defaultDialog(
                        title: "LOGOUT",
                        titleStyle: const TextStyle(fontSize: 20),
                        content: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text("Are you sure, you want to Logout?"),
                        ),
                        confirm: ElevatedButton(
                          onPressed: () => AuthenticationRepository.instance.logout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            side: BorderSide.none,
                          ),
                          child: const Text("Yes"),
                        ),
                        cancel: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text("No"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget menu item
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(LineAwesomeIcons.angle_right_solid, size: 18.0, color: Colors.grey),
      )
          : null,
    );
  }
}

/// Dummy class UpdateProfileScreen
class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: const Center(child: Text("Update Profile Screen")),
    );
  }
}

/// Dummy class AuthenticationRepository
class AuthenticationRepository {
  static final AuthenticationRepository instance = AuthenticationRepository();

  void logout() {
    Get.offAll(() => const LoginScreen()); // Điều hướng về màn hình đăng nhập
  }
}

/// Dummy class LoginScreen
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: const Center(child: Text("Login Screen")),
    );
  }
}
