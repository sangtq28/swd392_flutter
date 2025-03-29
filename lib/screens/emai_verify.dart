import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/pricing_page.dart';
import 'package:flutter_swd392/services/storage.service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../repository/user_repository.dart';
import 'current_package_screen.dart';

class EmailVerificationController extends GetxController {
  var isLoading = false.obs;
  var verificationSent = false.obs;
  var errorMessage = ''.obs;

  Future<void> verifyEmail(String token) async {
    isLoading.value = true;
    errorMessage.value = '';
    final userAuth = await StorageService.getAuthData();
    final token = userAuth?.token;
    if (token == null) {
      Get.snackbar(
        "Error",
        "User not authenticated",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://swd392-backend-fptu.growplus.hungngblog.com/api/Users/verify-email?token=$token'),
        headers: {
          'accept': '*/*',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        verificationSent.value = true;
        await Get.find<CurrentPackageController>().getCurrentUser(); // Update the user profile
        Get.snackbar(
          "Success",
          "Email verified successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );

        // Navigate to pricing page after successful verification
        Timer(const Duration(seconds: 2), () {
          Get.off(() => PricingPage());
        });
      } else {
        errorMessage.value = 'Verification failed. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Implement the API call to resend verification email
      // Use appropriate endpoint from your API
      await Future.delayed(const Duration(seconds: 2)); // Replace with actual API call

      Get.snackbar(
        "Email Sent",
        "Verification email has been sent to your email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
      );
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final EmailVerificationController controller = Get.put(EmailVerificationController());
  final TextEditingController tokenController = TextEditingController();

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Email Verification",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 48,
                color: Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Please verify your email address to access all features. Enter the verification token from your email below.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: "Verification Token",
                hintText: "Enter the token sent to your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                ),
                prefixIcon: const Icon(Icons.token, color: Color(0xFF64748B)),
              ),
            ),

            const SizedBox(height: 16),

            if (controller.errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () {
                  if (tokenController.text.isNotEmpty) {
                    controller.verifyEmail(tokenController.text);
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please enter verification token",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[100],
                      colorText: Colors.red[800],
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Verify Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: controller.isLoading.value ? null : () {
                controller.resendVerificationEmail();
              },
              child: const Text(
                "Didn't receive the email? Resend",
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}