import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/storage.service.dart';

class GrowthHistoryScreen extends StatefulWidget {
  final int childId;

  const GrowthHistoryScreen({super.key, required this.childId});

  @override
  _GrowthHistoryScreenState createState() => _GrowthHistoryScreenState();
}

class _GrowthHistoryScreenState extends State<GrowthHistoryScreen> {
  List<dynamic> growthIndicators = [];

  @override
  void initState() {
    super.initState();
    fetchGrowthIndicators();
  }

  Future<void> fetchGrowthIndicators() async {
    final String url = "https://swd392-backend-fptu.growplus.hungngblog.com/api/GrowthIndicators?childrenId=${widget.childId}";
    final userToken = await StorageService.getAuthData();
    final token = userToken?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to login first")),
      );
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token, // Thêm token vào headers
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody["status"] == "successful" && responseBody["data"] is List) {
          setState(() {
            growthIndicators = responseBody["data"]; // Gán đúng kiểu List
          });
        } else {
          print("⚠️ API Error: ${responseBody["message"]}");
        }
      } else {
        print("⚠️ Failed to fetch Growth Indicators: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching Growth Indicators: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Growth History")),
      body: growthIndicators.isEmpty
          ? Center(child: Text("No Growth Indicators found"))
          : ListView.builder(
        itemCount: growthIndicators.length,
        itemBuilder: (context, index) {
          final indicator = growthIndicators[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Height: ${indicator["height"]} cm, Weight: ${indicator["weight"]} kg"),
              subtitle: Text("Recorded on: ${indicator["recordTime"]}"),
            ),
          );
        },
      ),
    );
  }
}
