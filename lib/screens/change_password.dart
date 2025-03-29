import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/home_screen.dart';
import 'package:get/get.dart';
import '../repository/user_repository.dart';

class ResetPasswordController extends GetxController {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isPasswordMatched = true.obs;
  var isLoading = false.obs;
  var isOldPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void checkPasswordMatch() {
    isPasswordMatched.value = newPasswordController.text == confirmPasswordController.text;
  }

  Future<void> resetPassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters long");
      return;
    }

    if (oldPassword == newPassword) {
      Get.snackbar("Error", "New password cannot be the same as the old password");
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    isLoading.value = true;
    try {
      UserRepository userRepository = UserRepository();
      final isSuccess = await userRepository.updatePassword(oldPassword, newPassword);
      if (isSuccess) {
        Get.snackbar("Success", "Password updated successfully!");
        Get.offAll(() => HomeScreen());
      } else {
        Get.snackbar("Error", "Failed to update password. Try again.");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}



class ResetPasswordScreen extends StatelessWidget {
  final ResetPasswordController controller = Get.put(ResetPasswordController());

   ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.white70, // Màu header xanh đậm
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField("Old Password", controller.oldPasswordController, controller.isOldPasswordVisible),
            SizedBox(height: 20),
            _buildPasswordField("New Password", controller.newPasswordController, controller.isNewPasswordVisible),
            SizedBox(height: 20),
            _buildPasswordField(
                "Confirm New Password", controller.confirmPasswordController, controller.isConfirmPasswordVisible, isConfirm: true),
            SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isPasswordMatched.value &&
                    controller.oldPasswordController.text.isNotEmpty &&
                    controller.newPasswordController.text.isNotEmpty &&
                    controller.confirmPasswordController.text.isNotEmpty
                    ? () => controller.resetPassword()
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: controller.isPasswordMatched.value ? Colors.lightBlue : Colors.grey,
                ),
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("UPDATE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, RxBool isPasswordVisible, {bool isConfirm = false}) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black54)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible.value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter $label",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            suffixIcon: IconButton(
              icon: Icon(isPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.black),
              onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black54, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
            errorText: isConfirm &&
                controller.text.isNotEmpty &&
                controller.text != Get.find<ResetPasswordController>().newPasswordController.text
                ? "Passwords do not match"
                : null,
          ),
          onChanged: (val) {
            if (isConfirm) Get.find<ResetPasswordController>().checkPasswordMatch();
          },
        ),
      ],
    ));
  }
}
