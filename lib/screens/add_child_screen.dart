import 'package:flutter/material.dart';

import '../models/children_model.dart';
import '../repository/children_repository.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _chronicConditionsController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypeOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  bool _isLoading = false;

  // Define our app colors and theme
  final Color primaryColor = Color(0xFF4E7BF4);
  final Color secondaryColor = Color(0xFFF5F7FF);
  final Color accentColor = Color(0xFF3366CC);
  final Color backgroundColor = Color(0xFFF9FAFF);
  final Color textColor = Color(0xFF333B4F);

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final child = ChildrenModel(
      fullName: _nameController.text,
      avatar: "string",
      bloodType: _bloodTypeController.text,
      allergies: _allergiesController.text,
      chronicConditions: _chronicConditionsController.text,
      gender: _genderController.text,
      dob: _dobController.text,
    );

    try {
      await ChildrenRepository().addChildren(child);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Child added successfully!"),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add child: $e"),
          backgroundColor: Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: textColor,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              });
            }
          },
          decoration: InputDecoration(
            labelText: "Date of Birth",
            labelStyle: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            suffixIcon: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_today, color: primaryColor, size: 20),
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) => value == null || value.isEmpty ? "Date of Birth is required" : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(Icons.arrow_drop_down_circle, color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // Avatar functionality would go here
            },
            icon: Icon(Icons.add_a_photo, size: 16, color: primaryColor),
            label: Text(
              "Add Photo",
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Add Child Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildAvatarSelector(),
                const SizedBox(height: 20),
                _buildSectionHeader("Personal Information"),
                _buildTextField("Full Name", _nameController, Icons.person),
                _buildDatePicker(context),
                _buildDropdown("Gender", _genderOptions, _selectedGender, (value) {
                  setState(() {
                    _selectedGender = value;
                    _genderController.text = value ?? '';
                  });
                }),
                _buildSectionHeader("Medical Information"),
                _buildDropdown("Blood Type", _bloodTypeOptions, _selectedBloodType, (value) {
                  setState(() {
                    _selectedBloodType = value;
                    _bloodTypeController.text = value ?? '';
                  });
                }),
                _buildTextField("Allergies", _allergiesController, Icons.health_and_safety),
                _buildTextField("Chronic Conditions", _chronicConditionsController, Icons.medical_services),
                const SizedBox(height: 30),
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                )
                    : Center(
                  child: ElevatedButton(
                    onPressed: _addChild,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Save Child Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            prefixIcon: icon != null
                ? Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor, size: 20)
            )
                : null,
          ),
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
        ),
      ),
    );
  }
}