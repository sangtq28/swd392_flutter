import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/models/vaccine_schedule_model.dart';
import 'package:flutter_swd392/screens/create_record_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/storage.service.dart';
import '../models/vaccine_record_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class VaccineRecordListScreen extends StatefulWidget {
  @override
  _VaccineRecordListScreenState createState() => _VaccineRecordListScreenState();
}

class _VaccineRecordListScreenState extends State<VaccineRecordListScreen> {
  List<VaccineRecordModel> vaccineRecords = [];
  List<VaccineScheduleModel> vaccinationSchedules = [];
  List<VaccineScheduleModel> filteredSchedules = []; // For search results
  List<ChildrenModel> children = [];
  ChildrenModel? selectedChild;
  bool isLoading = true;
  bool isLoadingChildren = true;
  bool isLoadingSchedules = false;
  String status = "Vaccinated";

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    final String url = "https://swd392-backend-fptu.growplus.hungngblog.com/api/Children";
    final userToken = await StorageService.getAuthData();
    final token = userToken?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to login first")),
      );
      setState(() => isLoadingChildren = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody["data"] ?? [];

        setState(() {
          children = data.map((e) => ChildrenModel.fromJson(e)).toList();
          isLoadingChildren = false;

          // Select the first child by default if available
          if (children.isNotEmpty) {
            selectedChild = children.first;
            fetchVaccineRecords(selectedChild?.id ?? 0);
            fetchVaccinationSchedules();
          } else {
            isLoading = false;
          }
        });
      } else {
        print("⚠️ Failed to fetch children: ${response.body}");
        setState(() => isLoadingChildren = false);
      }
    } catch (e) {
      print("❌ Error fetching children: $e");
      setState(() => isLoadingChildren = false);
    }
  }

  Future<void> fetchVaccineRecords(int childId) async {
    setState(() => isLoading = true);

    final String url = "https://swd392-backend-fptu.growplus.hungngblog.com/api/VaccineRecords?childId=$childId";
    final userToken = await StorageService.getAuthData();
    final token = userToken?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to login first")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody["data"] ?? [];

        setState(() {
          vaccineRecords = data.map((e) => VaccineRecordModel.fromJson(e)).toList();

          // If we already have vaccination schedules, update their status
          if (vaccinationSchedules.isNotEmpty) {
            updateVaccinationStatus();
          }

          isLoading = false;
        });
      } else {
        print("⚠️ Failed to fetch vaccine records: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching vaccine records: $e");
      setState(() => isLoading = false);
    }
  }

  // New method to fetch vaccination schedules
  Future<void> fetchVaccinationSchedules() async {
    setState(() => isLoadingSchedules = true);

    final String url = "https://swd392-backend-fptu.growplus.hungngblog.com/api/VaccinationSchedules";
    final userToken = await StorageService.getAuthData();
    final token = userToken?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to login first")),
      );
      setState(() => isLoadingSchedules = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody["data"] ?? [];

        setState(() {
          vaccinationSchedules = data.map((e) => VaccineScheduleModel.fromJson(e)).toList();

          // If we already have vaccine records, update the vaccination status
          if (vaccineRecords.isNotEmpty) {
            updateVaccinationStatus();
          }

          isLoadingSchedules = false;
        });
      } else {
        print("⚠️ Failed to fetch vaccination schedules: ${response.body}");
        setState(() => isLoadingSchedules = false);
      }
    } catch (e) {
      print("❌ Error fetching vaccination schedules: $e");
      setState(() => isLoadingSchedules = false);
    }
  }

  // Method to determine if a vaccine has been administered
  bool isVaccinated(int vaccineId, int doseNumber) {
    return vaccineRecords.any((record) =>
    record.vaccineId == vaccineId &&
        record.dose == doseNumber);
  }
  void updateVaccinationStatus() {
    // Update status for each schedule by checking matching vaccine ID and dose
    for (var schedule in vaccinationSchedules) {
      if (schedule.vaccineId != null && schedule.doseNumber != null &&
          isVaccinated(schedule.vaccineId!, schedule.doseNumber!)) {
        status = "Vaccinated";
      }
    }
  }


  // Method to determine if a vaccine has been administered
  bool isVaccineAdministered(String vaccineName) {
    return vaccineRecords.any((record) =>
    record.vaccineName?.toLowerCase() == vaccineName.toLowerCase());
  }

  // Method to update vaccination status based on vaccine records
  void updateVaccinationStatuss() {
    // Mark schedules as "Vaccinated" if there's a matching vaccine record
    for (var schedule in vaccinationSchedules) {
      if (schedule.vaccineName != null &&
          isVaccineAdministered(schedule.vaccineName!)) {
        status = "Vaccinated";
      }
    }
  }

  String calculateAge(DateTime dateOfBirth) {
    final DateTime currentDate = DateTime.now();
    int age = currentDate.year - dateOfBirth.year;

    if (dateOfBirth.isAfter(currentDate)) {
      return "Invalid birthdate";
    }

    // Check if birthday has occurred this year
    if (currentDate.month < dateOfBirth.month ||
        (currentDate.month == dateOfBirth.month && currentDate.day < dateOfBirth.day)) {
      age--;
    }

    // Format age with years and months for younger children
    if (age < 2) {
      int months = currentDate.month - dateOfBirth.month;
      if (months < 0) months += 12;
      if (currentDate.day < dateOfBirth.day) months--;
      if (months < 0) months += 12;

      if (age == 0) {
        return "$months month${months != 1 ? 's' : ''}";
      } else {
        return "$age year${age != 1 ? 's' : ''}, $months month${months != 1 ? 's' : ''}";
      }
    }

    // Return just years for older children
    return "$age year${age != 1 ? 's' : ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: const Text(
          "Vaccine Records",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  if (selectedChild != null) {
                    fetchVaccineRecords(selectedChild!.id ?? 0);
                    fetchVaccinationSchedules();
                  } else {
                    fetchChildren();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child Selection Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFF7FAFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 12,
                      offset: Offset(-3, -3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: isLoadingChildren
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Color(0xFF3B82F6),
                      size: 40,
                    ),
                  ),
                )
                    : children.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.face_outlined,
                          color: Color(0xFF94A3B8),
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "No children found",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ButtonTheme(
                          alignedDropdown: true,
                          child: // Replace the entire DropdownButton implementation with this:
                          DropdownButton<ChildrenModel>(
                            isExpanded: true,
                            value: selectedChild,
                            icon: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF3B82F6),
                                size: 24,
                              ),
                            ),
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Select a child",
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            elevation: 8,
                            dropdownColor: Colors.white,
                            menuMaxHeight: 300,
                            itemHeight: 60, // Set a fixed height for items
                            onChanged: (ChildrenModel? newValue) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedChild = newValue;
                                if (newValue != null) {
                                  fetchVaccineRecords(newValue.id ?? 0);
                                  fetchVaccinationSchedules();
                                }
                              });
                            },
                            items: children.map<DropdownMenuItem<ChildrenModel>>((ChildrenModel child) {
                              return DropdownMenuItem<ChildrenModel>(
                                value: child,
                                child: SizedBox(
                                  height: 50, // Fixed height for the item content
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: child.avatar.isNotEmpty
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            child.avatar,
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  (child.fullName?.isNotEmpty == true)
                                                      ? child.fullName![0].toUpperCase()
                                                      : "?",
                                                  style: TextStyle(
                                                    color: Color(0xFF3B82F6),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            : Center(
                                          child: Text(
                                            (child.fullName?.isNotEmpty == true)
                                                ? child.fullName![0].toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              child.fullName ?? "Unknown",
                                              style: TextStyle(
                                                color: Color(0xFF1E293B),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.2,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            if (child.dob != null)
                                              Text(
                                                "Age: ${calculateAge(DateTime.parse(child.dob!))}",
                                                style: TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                selectedChild != null
                    ? "${selectedChild!.fullName}'s Records"
                    : "Your Records",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: isLoading || isLoadingSchedules
                  ? Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    color: Color(0xFF4F46E5),
                    strokeWidth: 3,
                  ),
                ),
              )
                  : vaccinationSchedules.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.vaccines_outlined,
                        size: 50,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      selectedChild != null
                          ? "No vaccination schedules for ${selectedChild!.fullName}"
                          : "No vaccination schedules available",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Add a new vaccination schedule to get started",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 20),
                itemCount: vaccinationSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = vaccinationSchedules[index];


                  // Determining color and status based on vaccination date and vaccine records
                  Color statusColor;
                  String statusText;

                  // Check if the vaccine has been administered
                  // Check if the vaccine has been administered by ID and dose number
                  if (schedule.vaccineId != null && schedule.doseNumber != null &&
                      isVaccinated(schedule.vaccineId!, schedule.doseNumber!)) {
                    statusColor = Color(0xFF10B981); // Modern emerald
                    statusText = "Vaccinated";
                  } else {
                    statusColor = Color(0xFFDC2626); // Modern red
                    statusText = "Not Yet";
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedChild?.fullName ?? "Unknown Child",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.vaccines,
                                size: 18,
                                color: Colors.blue[700],
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  schedule.vaccineName ?? "Unknown Vaccine",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Recommended Age: ${schedule.recommendedAgeMonths} months",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Dose: ${schedule.doseNumber}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(CreateVaccineRecordScreen());
        },
        backgroundColor: Colors.blue[700],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}