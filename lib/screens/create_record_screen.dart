import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/models/vaccine_model.dart';
import 'package:flutter_swd392/models/vaccine_schedule_model.dart';
import 'package:flutter_swd392/screens/home_screen.dart';
import 'package:flutter_swd392/screens/vaccine_record_list.dart';
import 'package:flutter_swd392/services/storage.service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CreateVaccineRecordScreen extends StatefulWidget {
  @override
  _CreateVaccineRecordScreenState createState() => _CreateVaccineRecordScreenState();
}

class _CreateVaccineRecordScreenState extends State<CreateVaccineRecordScreen> {
  List<ChildrenModel> children = [];
  List<VaccineModel> vaccines = [];
  VaccineScheduleModel? schedule;
  ChildrenModel? selectedChild;
  VaccineModel? selectedVaccine;
  String recommendationMessage = "";

  TextEditingController administeredDateController = TextEditingController();
  TextEditingController doseController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await Future.wait([
      fetchChildren(),
      fetchVaccines(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchChildren() async {
    try {
      final fetchedChildren = await ApiService.getChildren();
      setState(() {
        children = fetchedChildren;
      });
    } catch (e) {
      showError('Error fetching children: $e');
    }
  }

  Future<void> fetchVaccines() async {
    try {
      final response = await http.get(Uri.parse('https://swd392-backend-fptu.growplus.hungngblog.com/api/Vaccines'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          vaccines = (jsonData['data'] as List).map((e) => VaccineModel.fromJson(e)).toList();
        });
      } else {
        showError('Failed to load vaccines');
      }
    } catch (e) {
      showError('Error fetching vaccines: $e');
    }
  }

  Future<void> fetchSchedules(int vaccineId) async {
    try {
      setState(() => isLoading = true);
      final fetchedSchedule = await ApiService.getVaccinationSchedule(vaccineId);
      setState(() {
        schedule = fetchedSchedule;
        updateRecommendationMessage();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showError('Error fetching schedules: $e');
    }
  }

  void updateRecommendationMessage() {
    if (selectedChild != null && schedule != null) {
      int childAge = calculateAgeInMonths(selectedChild!.dob!);
      int recommendedAge = schedule!.recommendedAgeMonths!;

      if (childAge >= recommendedAge) {
        recommendationMessage = "✔ Trẻ đủ tuổi để tiêm vaccine này.";
      } else {
        recommendationMessage = "⚠ Trẻ chưa đủ tuổi. Cần chờ ${recommendedAge - childAge} tháng nữa.";
      }
    } else {
      recommendationMessage = "";
    }
  }

  int calculateAgeInMonths(String dob) {
    DateTime birthDate = DateFormat("yyyy-MM-dd").parse(dob);
    DateTime today = DateTime.now();
    return (today.year - birthDate.year) * 12 + (today.month - birthDate.month);
  }

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        administeredDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> createVaccineRecord() async {
    final userAuth = await StorageService.getAuthData();
    final token = userAuth?.token;
    if (token == null) {
      showError('Please login to create vaccine record');
      return;
    }

    if (selectedChild == null || selectedVaccine == null || administeredDateController.text.isEmpty) {
      showError('Please select all fields and enter valid data.');
      return;
    }

    int? doseNumber;
    try {
      doseNumber = int.parse(doseController.text);
    } catch (e) {
      showError('Dose must be a valid number');
      return;
    }
    String formattedDate = DateFormat('dd/MM/yyyy').format(
        DateFormat('yyyy-MM-dd').parse(administeredDateController.text)
    );
    print(formattedDate);
    print(selectedChild!.id);
    print(selectedVaccine!.id);
    print(schedule?.doseNumber);
    final body = jsonEncode({
      "childId": selectedChild!.id,
      "vaccineId": selectedVaccine!.id,
      "administeredDate": formattedDate,
      "dose": schedule?.doseNumber,
    });

    try {
      setState(() => isLoading = true);
      final response = await http.post(
        Uri.parse('https://swd392-backend-fptu.growplus.hungngblog.com/api/VaccineRecords'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: body,
      );
      print(response.body);

      setState(() => isLoading = false);
      if (response.statusCode == 201) {
        showSuccess('Vaccine record created successfully');

        // Clear fields after successful creation
        doseController.clear();
        administeredDateController.clear();
        setState(() {
          selectedChild = null;
          selectedVaccine = null;
          schedule = null;
          recommendationMessage = "";
        });
      } else {
        showError('Failed to create vaccine record');
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError('Error creating vaccine record: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 4),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Create Vaccine Record', style: TextStyle(color: Colors.white) ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.blue[700],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Vaccination Record',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Please fill in the details below',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Child Selection
                  _buildSectionTitle('Child Information'),
                  _buildCardSelector(
                    title: 'Select Child',
                    icon: Icons.child_care,
                    selectedValue: selectedChild?.fullName,
                    onPressed: () => _showChildSelectionBottomSheet(),
                  ),
                  if (selectedChild != null)
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        'Age: ${calculateAgeInMonths(selectedChild!.dob!) ~/ 12} years ${calculateAgeInMonths(selectedChild!.dob!) % 12} months',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Vaccine Selection
                  _buildSectionTitle('Vaccine Information'),
                  _buildCardSelector(
                    title: 'Select Vaccine',
                    icon: Icons.medication_liquid,
                    selectedValue: selectedVaccine?.name,
                    onPressed: () => _showVaccineSelectionBottomSheet(),
                  ),

                  // Vaccine Schedule Information
                  if (schedule != null) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vaccine Schedule',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.water_drop_outlined,
                            label: 'Recommended Dose',
                            value: '${schedule!.doseNumber}',
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.calendar_month,
                            label: 'Recommended Age',
                            value: '${schedule!.recommendedAgeMonths} months',
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: recommendationMessage.contains("✔") ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: recommendationMessage.contains("✔") ? Colors.green[200]! : Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  recommendationMessage.contains("✔") ? Icons.check_circle : Icons.warning,
                                  color: recommendationMessage.contains("✔") ? Colors.green[700] : Colors.red[700],
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    recommendationMessage.replaceAll("✔ ", "").replaceAll("⚠ ", ""),
                                    style: TextStyle(
                                      color: recommendationMessage.contains("✔") ? Colors.green[700] : Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 25),
                  _buildSectionTitle('Vaccination Details'),

                  // Date Field
                  _buildDateField(
                    controller: administeredDateController,
                    label: 'Administered Date',
                    onTap: selectDate,
                  ),

                  SizedBox(height: 15),

                  // Dose Field
                  _buildInputField(
                    controller: doseController..text = schedule?.doseNumber?.toString() ?? '',
                    label: 'Dose Number',
                    // keyboardType: TextInputType.number,
                    prefixIcon: Icons.format_list_numbered,
                  ),

                  SizedBox(height: 40),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: createVaccineRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create Vaccine Record',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
  Widget _buildCardSelector({
    required String title,
    required IconData icon,
    required String? selectedValue,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: selectedValue != null ? Colors.blue[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blue[700],
                size: 24,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      selectedValue ?? 'Please select',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selectedValue != null ? FontWeight.w600 : FontWeight.normal,
                        color: selectedValue != null ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[700]),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blue[700],
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showChildSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Child',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[700]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedChild = child;
                          if (selectedVaccine != null) {
                            updateRecommendationMessage();
                          }
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              radius: 25,
                              child: Text(
                                child.fullName?.substring(0, 1) ?? 'C',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.fullName ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Age: ${calculateAgeInMonths(child.dob!) ~/ 12} years ${calculateAgeInMonths(child.dob!) % 12} months',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: selectedChild?.id == child.id
                                  ? Colors.blue[700]
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVaccineSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Vaccine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[700]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: vaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = vaccines[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        setState(() {
                          selectedVaccine = vaccine;
                          schedule = null;
                          recommendationMessage = "";
                        });
                        await fetchSchedules(vaccine.id!);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.medication_liquid,
                                color: Colors.blue[700],
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vaccine.name ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    vaccine.description ?? 'No description available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: selectedVaccine?.id == vaccine.id
                                  ? Colors.blue[700]
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}