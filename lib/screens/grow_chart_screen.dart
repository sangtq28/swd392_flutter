import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/models/user_profile.dart';
import 'package:flutter_swd392/repository/user_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/storage.service.dart';

class GrowthChartScreen extends StatefulWidget {
  final int childId;

  const GrowthChartScreen({super.key, required this.childId});

  @override
  _GrowthChartScreenState createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  List<Map<String, dynamic>> growthData = [];
  String? rawAdvice = "Loading advice..."; // Lưu chuỗi thô từ API
  List<Widget> formattedAdvice = []; // Lưu danh sách widget đã format
  bool isLoadingAdvice = false;
  final String _apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyB7q4hFO8KQTDwDbrpq2I3S7ut363jo2y0"; // Thay bằng URL API Gemini thực tế
  UserProfile? userProfile;
  int? packageId;
  @override
  void initState() {
    super.initState();
    fetchGrowthHistory();
    getCurrentUser(); // Make sure to call this to get user profile with package info
  }
  Future<void> fetchGrowthHistory() async {
    final String url =
        "https://swd392-backend-fptu.growplus.hungngblog.com/api/GrowthIndicators?childrenId=${widget.childId}";

    try {
      final userToken = await StorageService.getAuthData();
      final token = userToken?.token;
      if (token == null) {
        print("⚠️ No JWT token found!");
        setState(() {
          rawAdvice = "Authentication error: No token found";
          formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
        });
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody["status"] == "successful" && responseBody["data"] is List) {
          List<Map<String, dynamic>> sortedData =
          List<Map<String, dynamic>>.from(responseBody["data"]);

          sortedData.sort((a, b) {
            DateTime dateA = DateFormat("dd/MM/yyyy").parse(a["recordTime"]);
            DateTime dateB = DateFormat("dd/MM/yyyy").parse(b["recordTime"]);
            return dateA.compareTo(dateB);
          });

          setState(() {
            growthData = sortedData;
            if (growthData.isNotEmpty) {
              // Only fetch AI advice if packageId is not 1
              if (packageId != 1) {
                fetchAIAdvice();
              } else {
                rawAdvice = "AI Health Advice is not available with your current package.";
                formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
              }
            } else {
              rawAdvice = "No growth data available for advice";
              formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
            }
          });
        } else {
          print("⚠️ API Error: ${responseBody["message"]}");
          setState(() {
            rawAdvice = "API Error: ${responseBody["message"]}";
            formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
          });
        }
      } else {
        print("⚠️ Failed to fetch Growth Indicators: ${response.body}");
        setState(() {
          rawAdvice = "Failed to fetch growth data: ${response.statusCode}";
          formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
        });
      }
    } catch (e) {
      print("❌ Error fetching Growth Indicators: $e");
      setState(() {
        rawAdvice = "Error fetching data: $e";
        formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
      });
    }
  }
  Future<void> getCurrentUser() async {
    final currUser = await UserRepository().getUserProfile();
    setState(() {
      userProfile = currUser;
      packageId = userProfile?.membershipPackageId; // Store the packageId
    });
  }
  Future<void> fetchAIAdvice() async {
    print(packageId);
    if (growthData.isEmpty) {
      setState(() {
        rawAdvice = "No growth data available for advice";
        formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
      });
      return;
    }

    setState(() {
      isLoadingAdvice = true;
      rawAdvice = "Loading advice...";
      formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
    });

    double currentBMI = growthData.last["bmi"] as double;
    await sendRequest(currentBMI);

    setState(() {
      isLoadingAdvice = false;
    });
  }

  Future<void> sendRequest(double bmi) async {
    final Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {
              "text":
              "Suggest a diet and exercise plan for a child with BMI $bmi. Only 300 words."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String advice = responseBody["candidates"][0]["content"]["parts"][0]["text"] ??
            "No advice available";
        setState(() {
          rawAdvice = advice;
          formattedAdvice = formatAdvice(advice);
        });
        print("✅ Success: $advice");
      } else {
        setState(() {
          rawAdvice = "Failed to get advice: ${response.statusCode} - ${response.body}";
          formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
        });
        print("⚠️ Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        rawAdvice = "Error: $e";
        formattedAdvice = [Text(rawAdvice!, style: const TextStyle(fontSize: 14, color: Colors.black87))];
      });
      print("❌ Error: $e");
    }
  }

  List<Widget> formatAdvice(String advice) {
    List<Widget> widgets = [];
    List<String> lines = advice.split('\n');
    bool inList = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        inList = false; // End list if empty line encountered
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Handle headers (** markers)
      if (line.startsWith('**') && line.endsWith('**')) {
        // Extract content between ** markers
        String title = line.substring(2, line.length - 2).trim();
        widgets.add(
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
        inList = false;
      }
      // Handle headers with ** markers anywhere in the text
      else if (line.contains('**')) {
        // Split the text by ** markers
        List<String> parts = line.split('**');
        List<InlineSpan> spans = [];

        for (int i = 0; i < parts.length; i++) {
          // Even indices are normal text, odd indices are bold
          spans.add(
            TextSpan(
              text: parts[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          );
        }

        widgets.add(
          RichText(
            text: TextSpan(children: spans),
          ),
        );
        widgets.add(const SizedBox(height: 8));
        inList = false;
      }
      // Handle list items (* markers)
      else if (line.startsWith('*') || line.startsWith('-') || line.startsWith('•')) {
        inList = true;
        // Remove the list marker and trim
        String item = line.replaceFirst(RegExp(r'^\*|-|•'), '').trim();

        // Handle bold text within list items
        if (item.contains('**')) {
          List<String> parts = item.split('**');
          List<InlineSpan> spans = [];

          for (int i = 0; i < parts.length; i++) {
            spans.add(
              TextSpan(
                text: parts[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            );
          }

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: spans),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        widgets.add(const SizedBox(height: 4));
      }
      // Handle paragraphs
      else {
        if (inList) {
          inList = false;
          widgets.add(const SizedBox(height: 8));
        }

        // Handle bold text within paragraphs
        if (line.contains('**')) {
          List<String> parts = line.split('**');
          List<InlineSpan> spans = [];

          for (int i = 0; i < parts.length; i++) {
            spans.add(
              TextSpan(
                text: parts[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            );
          }

          widgets.add(
            RichText(
              text: TextSpan(children: spans),
            ),
          );
        } else {
          widgets.add(
            Text(
              line,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          );
        }
        widgets.add(const SizedBox(height: 8));
      }
    }

    // Fallback if no widgets were created
    return widgets.isNotEmpty ? widgets : [Text(advice, style: const TextStyle(fontSize: 14, color: Colors.black87))];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: const Text(
          "Growth History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: growthData.isEmpty
          ? Center(
        child: Text(
          "No Growth Indicators Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "BMI Growth Chart",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(
                              "BMI",
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(
                              "Record Time",
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < growthData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      growthData[index]["recordTime"],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  );
                                }
                                return const Text("");
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.blue[200]!, width: 1),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.blue[100],
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.blue[100],
                            strokeWidth: 1,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: growthData.asMap().entries.map((entry) {
                              int index = entry.key;
                              double bmi = entry.value["bmi"].toDouble();
                              return FlSpot(index.toDouble(), bmi);
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue[700],
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                Color dotColor;
                                if (spot.y < 18.5) {
                                  dotColor = Colors.yellow[700]!;
                                } else if (spot.y >= 18.5 && spot.y < 25) {
                                  dotColor = Colors.green[700]!;
                                } else {
                                  dotColor = Colors.red[700]!;
                                }
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: dotColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue[300]!.withOpacity(0.3),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (LineBarSpot touchedSpot) {
                              if (touchedSpot.y < 18.5) {
                                return Colors.yellow[700]!.withOpacity(0.8);
                              } else if (touchedSpot.y >= 18.5 && touchedSpot.y < 25) {
                                return Colors.green[700]!.withOpacity(0.8);
                              } else {
                                return Colors.red[700]!.withOpacity(0.8);
                              }
                            },
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot touchedSpot) {
                                final index = touchedSpot.x.toInt();
                                if (index >= 0 && index < growthData.length) {
                                  String status;
                                  if (touchedSpot.y < 18.5) {
                                    status = "Underweight";
                                  } else if (touchedSpot.y >= 18.5 && touchedSpot.y < 25) {
                                    status = "Normal";
                                  } else {
                                    status = "Overweight";
                                  }
                                  return LineTooltipItem(
                                    'BMI: ${touchedSpot.y.toStringAsFixed(1)}\n${growthData[index]["recordTime"]}\nStatus: $status',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Conditional rendering based on packageId
              packageId == 1
                  ? _buildPremiumPromotion(context)
                  : _buildAIHealthAdvice(),
              const SizedBox(height: 20),
              if (packageId != 1) ...[
                Text(
                  "AI Health Advice:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 10),
                isLoadingAdvice
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formattedAdvice,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPremiumPromotion(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.purple[500]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 24,
                      color: Colors.amber[300],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "AI INSIGHTS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.amber[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Unlock Premium Health Insights",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Get personalized AI recommendations for your child's optimal diet and exercise plan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    // Navigate to CurrentPackagePlan
                    Navigator.pushNamed(context, '/currentPackagePlan');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Upgrade Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.blue[800],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Add this method for the AI health advice
  Widget _buildAIHealthAdvice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Health Advice:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 10),
        isLoadingAdvice
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formattedAdvice,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}