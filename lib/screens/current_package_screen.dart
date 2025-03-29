import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:flutter_swd392/models/user_profile.dart';
import 'package:flutter_swd392/screens/home_screen.dart';
import 'package:flutter_swd392/screens/pricing_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/membership/membership_subscript.dart';
import '../repository/user_repository.dart';
import 'emai_verify.dart';

class CurrentPackageController extends GetxController {
  static const int _selectedIndex = 3; // Index của Profile
  var currentPackage = Rxn<MembershipSubscriptionModel>();
  var isLoading = false.obs;
  var startDate = "".obs;
  var endDate = "".obs;
  var remainingDays = 0.obs;
  UserProfile? userProfile;

  @override
  void onInit() {
    getCurrentUser();
    fetchCurrentPackage();
    super.onInit();
  }

  Future<void> getCurrentUser() async {
    final user = await UserRepository().getUserProfile();
    if (user != null) {
      userProfile = user;
    }
  }
  // Add to CurrentPackageController class
  void checkEmailActivationAndNavigate() {
    // Check if userProfile is null or not fetched yet
    if (userProfile == null) {
      // Fetch user profile first
      getCurrentUser().then((_) {
        _navigateBasedOnEmailActivation();
      });
    } else {
      _navigateBasedOnEmailActivation();
    }
  }

  void _navigateBasedOnEmailActivation() {
    if (userProfile?.emailActivation?.toLowerCase() == "activated") {
      // Email is activated, proceed to pricing page
      Get.to(() => PricingPage());
    } else {
      // Email is not activated, go to verification screen
      Get.to(() => const EmailVerificationScreen());
    }
  }


  Future<void> fetchCurrentPackage() async {
    isLoading.value = true;
    try {
      final data = await UserRepository().getCurrentPackage();
      print("🔵 Raw JSON response: $data"); // In ra để kiểm tra

      if (data != null) {
        currentPackage.value = data;
        startDate.value = data.startDate.isNotEmpty ? _formatDate(data.startDate) : "N/A";
        endDate.value = data.endDate.isNotEmpty ? _formatDate(data.endDate) : "N/A";

        // Calculate remaining days
        if (data.endDate.isNotEmpty) {
          final end = DateTime.parse(data.endDate);
          final now = DateTime.now();
          remainingDays.value = end.difference(now).inDays;
        }
      } else {
        currentPackage.value = null;
        startDate.value = "N/A";
        endDate.value = "N/A";
        remainingDays.value = 0;
      }
    } catch (e) {
      print("🔴 Error parsing package: $e");
      Get.snackbar("Error", "Failed to load package: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm format ngày
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date); // Ví dụ: 06/03/2025
    } catch (e) {
      return "Invalid date";
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    final dateTime = DateTime.parse(dateStr);
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }
}

class CurrentPackageScreen extends StatelessWidget {
  final CurrentPackageController controller = Get.put(CurrentPackageController());
  static const int _selectedIndex = 3;

  CurrentPackageScreen({super.key}); // Index của Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () =>
          {
            Get.back(),
          },
        ),
        title: const Text(
          "Membership",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add refresh button to the app bar
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              controller.fetchCurrentPackage(); // Call the fetch method when pressed
              Get.snackbar(
                "Refreshing",
                "Updating membership information...",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                colorText: const Color(0xFF3B82F6),
                duration: const Duration(seconds: 2),
              );
            },
          ),
          IconButton(
            icon: const Icon(
                Icons.help_outline_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              // Show help info
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3B82F6),
              strokeWidth: 3,
            ),
          );
        }

        if (controller.currentPackage.value == null) {
          return _buildNoPackageView(context);
        }

        final package = controller.currentPackage.value!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Status bar with remaining days
              _buildStatusBar(controller.remainingDays.value),

              const SizedBox(height: 24),

              // Membership card
              _buildMembershipCard(package),

              const SizedBox(height: 24),

              // Features section
              Expanded(
                child: _buildFeaturesSection(package),
              ),

              // Add a refresh button in the content area too for convenience
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    controller.fetchCurrentPackage();
                    Get.snackbar(
                      "Refreshing",
                      "Updating membership information...",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                      colorText: const Color(0xFF3B82F6),
                      duration: const Duration(seconds: 2),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text("Refresh Membership Info"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                  ),
                ),
              ),

              // Upgrade button
              _buildUpgradeButton(context),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoPackageView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.card_membership_outlined,
              size: 48,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Active Membership",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Subscribe to a membership plan to unlock premium features and benefits",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Add refresh button to no package view too
          TextButton.icon(
            onPressed: () {
              controller.fetchCurrentPackage();
              Get.snackbar(
                "Refreshing",
                "Checking for membership updates...",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                colorText: const Color(0xFF3B82F6),
                duration: const Duration(seconds: 2),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text("Refresh"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              controller.checkEmailActivationAndNavigate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "View Plans",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(int daysLeft) {
    final statusColor = daysLeft < 7
        ? const Color(0xFFF97316) // Orange for soon expiry
        : const Color(0xFF10B981); // Green for active

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            daysLeft < 7 ? Icons.timer_outlined : Icons.check_circle_outline,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              daysLeft < 7
                  ? "Your membership expires in $daysLeft days"
                  : "Active membership • $daysLeft days remaining",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(MembershipSubscriptionModel package) {
    List<Color> gradientColors;

    // Standardize case for comparison to avoid case-sensitivity issues
    String packageName = package.package?.name?.toLowerCase() ?? "";

    switch (packageName) {
      case "basic":
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF0EA5E9)]; // Blue gradient
        break;
      case "standard":
        gradientColors = [const Color(0xFFF97316), const Color(0xFFFB923C)]; // Orange gradient
        break;
      case "enterprise":
        gradientColors = [const Color(0xFF10B981), const Color(0xFF059669)]; // Green gradient
        break;
      default:
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF0EA5E9)]; // Default blue
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                package.package?.name ?? "Unknown",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Text(
                  "ACTIVE", // Always show as active
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                "\$${package.package?.price ?? '0'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "/month",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "START DATE",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.startDate.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "END DATE",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.endDate.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(MembershipSubscriptionModel package) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Included Features",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ...package.package?.permissions.map((permission) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                permission.description ?? "Feature",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList() ?? [],
            ],
          ),
        ),
      ),
    );
  }

  // Fix the upgrade button to handle all plan types correctly
  Widget _buildUpgradeButton(BuildContext context) {
    // Get the package name and standardize to lowercase for comparison
    final packageName = controller.currentPackage.value?.package?.name?.toLowerCase() ?? "";

    // Only disable the button for Enterprise plan
    final isEnterprise = packageName == "enterprise";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: isEnterprise ? null : () {
          _showUpgradeDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnterprise ? Colors.grey : const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isEnterprise ? "Highest Plan" : "Upgrade Membership",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.upgrade_rounded,
                      size: 32,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Upgrade Your Membership",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Unlock premium features by upgrading to a higher tier. Are you ready to enhance your experience?",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            "Not Now",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.checkEmailActivationAndNavigate();
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
                          child: const Text(
                            "View Plans",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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