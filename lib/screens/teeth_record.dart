import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/screens/create_teeth.dart';
import 'package:http/http.dart' as http;
import '../models/teeth_record.dart';
import '../models/tooth_model.dart';
import '../services/storage.service.dart';
import 'package:intl/intl.dart';

class TeethRecordsScreen extends StatefulWidget {
  final ChildrenModel childModel;
  const TeethRecordsScreen({super.key, required this.childModel});

  @override
  State<TeethRecordsScreen> createState() => _TeethRecordsScreenState();
}

class _TeethRecordsScreenState extends State<TeethRecordsScreen> {
  List<TeethRecordModel> records = [];
  ToothModel? tooth;
  bool isLoading = false;
  bool hasNextPage = true;
  DateTime? startTime;
  DateTime? endTime;
  final ScrollController _scrollController = ScrollController();

  // Define the main blue color and other theme colors
  final Color mainBlue = const Color(0xFF1976D2);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color white = Colors.white;

  @override
  void initState() {
    super.initState();

    // Convert the DOB string to DateTime object
    try {
      if (widget.childModel.dob.isNotEmpty) {
        // Try to parse the DOB string using different formats
        startTime = _parseDate(widget.childModel.dob);
      }
    } catch (e) {
      print("Error parsing DOB: $e");
    }

    // Fallback to 30 days ago if DOB parsing fails
    startTime ??= DateTime.now().subtract(const Duration(days: 30));
    endTime = DateTime.now();

    _loadInitialData();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && hasNextPage && !isLoading) {
        fetchRecords(isLoadMore: true);
      }
    });
  }


  // Helper method to try parsing dates in different formats
  DateTime? _parseDate(String dateStr) {
    // Try different date formats commonly used
    final formats = [
      'dd/MM/yyyy',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'd/M/yyyy',
      'yyyy/MM/dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateStr);
      } catch (e) {
        // Try next format
      }
    }

    return null; // If all parsing attempts fail
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await fetchRecords();
    } catch (e) {
      _showSnackBar('Lỗi khởi tạo dữ liệu: $e');
    }
  }
  Future<ToothModel?> fetchTeeth(int teethId) async {
    final token = await _getToken();
    if (token == null) return null;
    print("Token: $token");
    print("Teeth ID: $teethId");

    try {
      final response = await http.get(
        Uri.parse("https://swd39220250217220816.azurewebsites.net/api/Teeth/$teethId"),
        headers: {"Content-Type": "application/json", "Authorization": token},
      );
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        tooth = ToothModel.fromJson(jsonResponse);
        return tooth;
      } else {
        _showSnackBar('Lỗi tải dữ liệu răng: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e');
      return null;
    }
  }


  Future<String?> _getToken() async {
    final userToken = await StorageService.getAuthData();
    final token = userToken?.token;
    if (token == null) {
      _showSnackBar('Bạn cần đăng nhập trước');
      return null;
    }
    return token;
  }

  Future<void> fetchRecords({bool isLoadMore = false}) async {
    if (startTime == null || endTime == null) return;

    final token = await _getToken();
    if (token == null) return;

    setState(() => isLoading = true);

    // Fixed: Use dd/MM/yyyy format as required by the API
    final url = Uri.parse(
      "https://swd39220250217220816.azurewebsites.net/api/TeethingRecords"
          "?childId=${widget.childModel.id}"
          "&startTime=${_formatDate(startTime!)}"
    );

    print("API Request URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (isLoadMore) {
            records.addAll((data['data'] as List)
                .map((e) => TeethRecordModel.fromJson(e))
                .toList());
          } else {
            records = (data['data'] as List)
                .map((e) => TeethRecordModel.fromJson(e))
                .toList();
          }
          hasNextPage = data['pagination']['hasNextPage'];
        });
      } else {
        _showSnackBar('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Format date for API request in dd/MM/yyyy format
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  // Format date for display
  String _formatDisplayDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? startTime! : endTime!;
    final firstDate = widget.childModel.dob.isNotEmpty
        ? _parseDate(widget.childModel.dob) ?? DateTime(2020)
        : DateTime(2020);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: mainBlue,
            onPrimary: white,
            surface: white,
          ),
          dialogBackgroundColor: white,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startTime = picked;
          // Fix: Ensure end date is not before start date
          if (endTime!.isBefore(startTime!)) {
            endTime = startTime!.add(const Duration(days: 1));
          }
        } else {
          endTime = picked;
          // Fix: Ensure start date is not after end date
          if (startTime!.isAfter(endTime!)) {
            startTime = endTime!.subtract(const Duration(days: 1));
          }
        }
      });
      await fetchRecords();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Teething Records', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: mainBlue,
        foregroundColor: white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchRecords(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: isLoading && records.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: mainBlue),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(color: mainBlue),
                  ),
                ],
              ),
            )
                : records.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: mainBlue.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu trong khoảng thời gian này',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainBlue,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.date_range),
                    label: const Text('Thay đổi khoảng thời gian'),
                  ),
                ],
              ),
            )
                : _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if childId is not null before passing it
          if (widget.childModel.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateTeethRecordScreen(childId: widget.childModel.id!)),
            );
          } else {
            // Handle the case where id is null (show error, etc.)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Child ID is missing')),
            );
          }
        },
        backgroundColor: mainBlue,
        foregroundColor: white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateFilterChip(true, startLabel: 'Từ ngày')),
              const SizedBox(width: 12),
              Expanded(child: _buildDateFilterChip(false, startLabel: 'Đến ngày')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterChip(bool isStartDate, {required String startLabel}) {
    final date = isStartDate ? startTime : endTime;

    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mainBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: darkBlue.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null ? _formatDisplayDate(date) : 'Chọn ngày',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: mainBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return RefreshIndicator(
      onRefresh: () => fetchRecords(),
      color: mainBlue,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: records.length + (hasNextPage ? 1 : 0),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (index == records.length && hasNextPage) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: mainBlue),
              ),
            );
          }
          if (index < records.length) {
            return _buildRecordCard(records[index], index);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRecordCard(TeethRecordModel record, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(
        bottom: 12,
        top: index == 0 ? 4 : 0,
      ),
      child: Card(
        elevation: 1,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: mainBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // Handle tapping on record - open details
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: mainBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.eruptionDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        // Show options for this record
                      },
                    ),
                  ],
                ),
                FutureBuilder<ToothModel?>(
                    future: fetchTeeth(record.toothId),
                    builder: (context, snapshot) {
                      return _buildInfoItem(
                        icon: Icons.nature,
                        label: 'Răng: ${record.toothId}',
                        value: snapshot.hasData && snapshot.data != null
                            ? snapshot.data!.name  // Assuming ToothModel has a 'name' property
                            : 'Đang tải...',
                      );
                    },
                ),
                _buildInfoItem(
                  icon: Icons.child_care,
                  label: 'Trẻ',
                  value: widget.childModel.fullName ?? 'Không có tên',
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Ngày mọc răng',
                  value: record.eruptionDate,
                ),
                // _buildInfoItem(
                //   icon: Icons.access_time,
                //   label: 'Thời gian',
                //   value: record.recordTime,
                // ),
                if (record.note.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.notes,
                    label: 'Ghi chú',
                    value: record.note,
                    isNote: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isNote = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: darkBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isNote ? 14 : 15,
                    fontWeight: isNote ? FontWeight.normal : FontWeight.w500,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}