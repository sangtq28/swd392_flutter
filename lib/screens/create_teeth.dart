import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/tooth_model.dart';
import '../services/storage.service.dart';

class CreateTeethRecordScreen extends StatefulWidget {
  final int childId;
  const CreateTeethRecordScreen({super.key, required this.childId});

  @override
  _CreateTeethRecordScreenState createState() => _CreateTeethRecordScreenState();
}

class _CreateTeethRecordScreenState extends State<CreateTeethRecordScreen> {
  List<ToothModel> teeth = [];
  ToothModel? selectedTooth;
  DateTime? eruptionDate;
  DateTime? recordTime;
  TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  // Removed all animation-related code

  @override
  void initState() {
    super.initState();
    fetchTeeth();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> fetchTeeth() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
          Uri.parse("https://swd392-backend-fptu.growplus.hungngblog.com/api/api/Teeth"));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          teeth = jsonResponse.map((data) => ToothModel.fromJson(data)).toList();
        });
      } else {
        _showSnackBar("Failed to load teeth data. Please try again.");
      }
    } catch (e) {
      _showSnackBar("Network error. Please check your connection.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isEruptionDate) async {
    final ThemeData theme = Theme.of(context);
    final DateTime initialDate = isEruptionDate && eruptionDate != null
        ? eruptionDate!
        : !isEruptionDate && recordTime != null
        ? recordTime!
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF6366F1), // Indigo color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isEruptionDate) {
          eruptionDate = picked;
        } else {
          recordTime = picked;
        }
      });
    }
  }

  Future<void> createRecord() async {
    if (selectedTooth == null || eruptionDate == null || recordTime == null) {
      _showSnackBar("Please fill in all required fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Format dates as dd/MM/yyyy
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final String formattedEruptionDate = formatter.format(eruptionDate!);
      final String formattedRecordTime = formatter.format(recordTime!);

      final body = jsonEncode({
        "childId": widget.childId,
        "toothId": selectedTooth!.id,
        "eruptionDate": formattedEruptionDate,
        "recordTime": formattedRecordTime,
        "note": noteController.text
      });

      final userToken = await StorageService.getAuthData();
      final token = userToken?.token;

      if (token == null) {
        _showSnackBar("You need to login first");
        return;
      }

      final response = await http.post(
          Uri.parse("https://swd392-backend-fptu.growplus.hungngblog.com/api/TeethingRecords"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token
          },
          body: body
      );

      // For debugging
      print(formattedEruptionDate);
      print(formattedRecordTime);

      if (response.statusCode == 201) {
        _showSnackBar("Record created successfully!");
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showSnackBar("Error creating record. Please try again.");
      }
    } catch (e) {
      _showSnackBar("Network error. Please check your connection.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "New Teeth Record",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Simple placeholder icon
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.child_care, size: 60, color: Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(height: 24),

                // Form fields
                _buildFormSection(
                  title: "Tooth Information",
                  child: _buildToothSelector(),
                ),

                const SizedBox(height: 16),

                _buildFormSection(
                  title: "Date Information",
                  child: Column(
                    children: [
                      _buildDateField(
                        title: "Eruption Date",
                        hint: "When did the tooth appear?",
                        value: eruptionDate,
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _selectDate(context, true),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        title: "Record Date",
                        hint: "When are you recording this?",
                        value: recordTime,
                        icon: Icons.event_note_rounded,
                        onTap: () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildFormSection(
                  title: "Additional Notes",
                  child: _buildNoteField(),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isLoading ? null : createRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.transparent,
            ),
            child: Text(
              isLoading ? "Creating..." : "Save Record",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildToothSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<ToothModel>(
        value: selectedTooth,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        hint: const Text("Select a tooth"),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF6366F1),
        ),
        items: teeth.map((tooth) {
          return DropdownMenuItem(
            value: tooth,
            child: Text(
              tooth.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedTooth = value;
          });
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildDateField({
    required String title,
    required String hint,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final String displayText = value != null
        ? DateFormat('dd/MM/yyyy').format(value)
        : hint;

    final Color textColor = value != null
        ? Colors.black87
        : Colors.grey.shade500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: noteController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Add any observations or notes about this tooth...",
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}