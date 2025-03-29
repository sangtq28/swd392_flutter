import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../repository/user_repository.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isEditing = false.obs;
  var userProfile = {}.obs;
  var avatarLoading = false.obs;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController avatarController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    final data = await UserRepository().getUserProfile();
    if (data != null) {
      userProfile.value = data.toJson();
      fullNameController.text = data.fullName;
      emailController.text = data.email;
      phoneController.text = data.phoneNumber ?? "123456789";
      avatarController.text = data.avatar;
    }
    isLoading.value = false;
  }
}

class EditProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: controller.isEditing.value ? 1.0 : 0.0,
          child: Text(
            "Edit Profile",
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        )),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isEditing.value ? Icons.close_rounded : Icons.edit_rounded,
              color: Color(0xFF1E293B),
            ),
            onPressed: () => controller.toggleEditing(),
          )),
        ],
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      )
          : CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Personal Information"),
                  SizedBox(height: 24),
                  _buildTextField(
                    "Full Name",
                    controller.fullNameController,
                    Icons.person_rounded,
                    controller.isEditing.value,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    "Email",
                    controller.emailController,
                    Icons.email_rounded,
                    false,
                    isEmail: true,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    "Phone",
                    controller.phoneController,
                    Icons.phone_rounded,
                    controller.isEditing.value,
                  ),
                  SizedBox(height: 40),
                  Obx(() => controller.isEditing.value
                      ? _buildSaveButton()
                      : SizedBox()),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient with design elements
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF4338CA),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative floating circles
                  Positioned(
                    top: -30,
                    left: -20,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: -40,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Avatar placement with neumorphic effect
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() => controller.avatarLoading.value
                        ? Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
                        ),
                      ),
                    )
                        : Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: Color(0xFFE2E8F0),
                          backgroundImage: NetworkImage(
                            controller.avatarController.text,
                          ),
                          onBackgroundImageError: (_, __) {},
                          child: controller.avatarController.text.isEmpty
                              ? Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Color(0xFF94A3B8),
                          )
                              : null,
                        ),
                      ),
                    )),
                    Obx(() => Positioned(
                      bottom: 0,
                      right: 0,
                      child: Visibility(
                        visible: controller.isEditing.value,
                        child: GestureDetector(
                          onTap: () {
                            // Avatar change functionality would go here
                            Get.snackbar(
                              "Feature Coming Soon",
                              "Avatar upload will be available in the next update",
                              backgroundColor: Color(0xFF6366F1),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 16,
                              duration: Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
          // Profile name display
          // Replace this part in the _buildProfileHeader() function
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      bool isEditable, {
        bool isEmail = false,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditable
              ? Color(0xFFE2E8F0)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isEditable
            ? [
          BoxShadow(
            color: Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            readOnly: !isEditable,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isEmail
                    ? Color(0xFF94A3B8)
                    : isEditable
                    ? Color(0xFF6366F1)
                    : Color(0xFF94A3B8),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final updatedData = {
              "phoneNumber": controller.phoneController.text,
              "password": controller.userProfile["password"],
              "fullName": controller.fullNameController.text,
              "avatar": controller.userProfile["avatar"],
              "role": controller.userProfile["role"],
              "status": controller.userProfile["status"],
              "membershipPackageId": controller.userProfile["membershipPackageId"],
              "uid": controller.userProfile["uid"],
              "address": controller.userProfile["address"],
              "zipcode": controller.userProfile["zipcode"],
              "state": controller.userProfile["state"],
              "country": controller.userProfile["country"],
            };
            final isSuccess = await UserRepository().updateUserProfile(updatedData);
            if (isSuccess) {
              Get.snackbar(
                "Profile Updated",
                "Your information has been saved successfully",
                backgroundColor: Color(0xFF10B981),
                colorText: Colors.white,
                margin: EdgeInsets.all(16),
                borderRadius: 16,
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
                icon: Icon(Icons.check_circle_rounded, color: Colors.white),
              );
              controller.toggleEditing();
            } else {
              Get.snackbar(
                "Update Failed",
                "Something went wrong. Please try again.",
                backgroundColor: Color(0xFFEF4444),
                colorText: Colors.white,
                margin: EdgeInsets.all(16),
                borderRadius: 16,
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
                icon: Icon(Icons.error_rounded, color: Colors.white),
              );
            }
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}