import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart'; // Added for Rxn
import '../models/children_model.dart';
import '../repository/children_repository.dart';
import '../services/storage.service.dart';
import 'growth_incdicator.dart';

class ChildDetailScreen extends StatefulWidget {
  final int childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  _ChildDetailScreenState createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> with SingleTickerProviderStateMixin {
  final ChildrenRepository _childrenRepository = ChildrenRepository();
  late Future<ChildrenModel> _childFuture;
  bool _isEditing = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  final ImagePicker _picker = ImagePicker();
  final Rxn<File> _selectedImage = Rxn<File>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _chronicConditionsController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // New for age
  final TextEditingController _statusController = TextEditingController(); // New for status

  @override
  void initState() {
    super.initState();
    _childFuture = _childrenRepository.getChildById(widget.childId);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectedImage.close();
    super.dispose();
  }

  void _enableEditing(ChildrenModel child) {
    setState(() {
      _isEditing = true;
      _nameController.text = child.fullName;
      _dobController.text = child.dob;
      _bloodTypeController.text = child.bloodType;
      _allergiesController.text = child.allergies;
      _chronicConditionsController.text = child.chronicConditions;
      _genderController.text = child.gender;
    });
  }

  Future<void> _editChild() async {
    setState(() {
      _isLoading = true;
    });

    final url = "https://swd392-backend-fptu.growplus.hungngblog.com/api/Children/${widget.childId}";
    final userAuth = await StorageService.getAuthData();
    final token = userAuth?.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Authentication token not found'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "accept": "*/*",
        "Authorization": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fullName": _nameController.text,
        "age": int.tryParse(_ageController.text) ?? 0,
        "avatar": _selectedImage.value != null ? '' : '', // Update this logic if avatar URL is managed differently
        "dob": _dobController.text,
        "bloodType": _bloodTypeController.text,
        "allergies": _allergiesController.text,
        "chronicConditions": _chronicConditionsController.text,
        "gender": _genderController.text,
        "status": int.tryParse(_statusController.text) ?? 0,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        _isEditing = false;
        _childFuture = _childrenRepository.getChildById(widget.childId);
      });

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Profile updated successfully", style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text("Failed to update profile: ${response.statusCode}", style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
        ),
      );
    }
  }

  Future<void> pickChildImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage.value = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> uploadChildAvatar() async {
    if (_selectedImage.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('No image selected'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userAuth = await StorageService.getAuthData();
      final token = userAuth?.token;
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://swd392-backend-fptu.growplus.hungngblog.com/api/Children/UploadAvatar/${widget.childId}'),
      );

      request.headers.addAll({
        'accept': 'text/plain',
        'Authorization': token,
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedImage.value!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200 && jsonResponse['status'] == 'successful') {
        setState(() {
          _childFuture = _childrenRepository.getChildById(widget.childId); // Refresh child data
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Child avatar uploaded successfully'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        throw Exception('Upload failed: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload avatar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _selectedImage.value = null; // Clear the selected image after upload
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Child Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        scrolledUnderElevation: 0,
        actions: [
          FutureBuilder<ChildrenModel>(
            future: _childFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _isEditing
                      ? IconButton(
                    icon: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.indigo.shade700,
                      ),
                    )
                        : Icon(Icons.check_rounded, color: Colors.indigo.shade700),
                    onPressed: _isLoading ? null : _editChild,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black12,
                    ),
                  )
                      : IconButton(
                    icon: Icon(Icons.edit_rounded, color: Colors.indigo.shade700),
                    onPressed: () => _enableEditing(snapshot.data!),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black12,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: FutureBuilder<ChildrenModel>(
        future: _childFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.indigo.shade700,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading data",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No profile data found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          final child = snapshot.data!;
          if (!_isEditing) {
            _nameController.text = child.fullName;
            _dobController.text = child.dob;
            _bloodTypeController.text = child.bloodType;
            _allergiesController.text = child.allergies;
            _chronicConditionsController.text = child.chronicConditions;
            _genderController.text = child.gender;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade100, Colors.blue.shade50],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: FadeTransition(
                      opacity: _animationController.drive(CurveTween(curve: Curves.easeIn)),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _isLoading ? null : pickChildImage,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: child.avatar.isNotEmpty
                                ? NetworkImage(child.avatar)
                                : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                            foregroundImage: _selectedImage.value != null
                                ? FileImage(_selectedImage.value!)
                                : null,
                            onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 70, color: Colors.grey),
                            child: _selectedImage.value != null
                                ? null
                                : Icon(Icons.camera_alt, size: 40, color: Colors.indigo.shade400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _fadeInSlide(
                      delay: 100,
                      child: const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _fadeInSlide(
                      delay: 200,
                      child: _buildInfoField(Icons.person_rounded, "Full Name", _nameController, child.fullName),
                    ),
                    const SizedBox(height: 20),
                    _fadeInSlide(
                      delay: 300,
                      child: _buildInfoField(Icons.calendar_today_rounded, "Date of Birth", _dobController, child.dob),
                    ),
                    const SizedBox(height: 20),
                    _fadeInSlide(
                      delay: 500,
                      child: _buildInfoField(Icons.bloodtype_rounded, "Blood Type", _bloodTypeController, child.bloodType),
                    ),
                    const SizedBox(height: 20),
                    _fadeInSlide(
                      delay: 600,
                      child: _buildInfoField(Icons.wc_rounded, "Gender", _genderController, child.gender),
                    ),
                    const SizedBox(height: 32),
                    _fadeInSlide(
                      delay: 800,
                      child: const Text(
                        "Health Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _fadeInSlide(
                      delay: 900,
                      child: _buildInfoField(Icons.warning_amber_rounded, "Allergies", _allergiesController, child.allergies),
                    ),
                    const SizedBox(height: 20),
                    _fadeInSlide(
                      delay: 1000,
                      child: _buildInfoField(Icons.health_and_safety_rounded, "Chronic Conditions", _chronicConditionsController, child.chronicConditions),
                    ),
                    const SizedBox(height: 40),
                    _fadeInSlide(
                      delay: 1100,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrowthIndicatorScreen(childrenId: widget.childId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.show_chart_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Growth Indicators",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _fadeInSlide(
                      delay: 1200,
                      child: ElevatedButton(
                        onPressed: _isLoading || _selectedImage.value == null
                            ? null
                            : () async {
                          await uploadChildAvatar();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Upload Avatar",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fadeInSlide({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1000,
            1.0,
            curve: Curves.easeOut,
          ),
        );

        return Opacity(
          opacity: delayedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildInfoField(IconData icon, String label, TextEditingController controller, String initialValue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isEditing
            ? [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.indigo.shade400),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade400,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: controller,
            enabled: _isEditing,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            style: TextStyle(
              color: _isEditing ? Colors.black87 : Colors.black54,
              fontWeight: _isEditing ? FontWeight.w500 : FontWeight.w400,
              fontSize: 16,
            ),
            cursorColor: Colors.indigo.shade700,
            keyboardType: label == "Age" || label == "Status" ? TextInputType.number : TextInputType.text,
          ),
        ],
      ),
    );
  }
}
