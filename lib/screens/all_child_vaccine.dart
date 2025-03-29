import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/create_record_screen.dart';
import '../models/children_model.dart';
import '../repository/children_repository.dart';

class AllChildVaccine extends StatefulWidget {
  const AllChildVaccine({super.key});

  @override
  _AllChildVaccineState createState() => _AllChildVaccineState();
}

class _AllChildVaccineState extends State<AllChildVaccine> {
  final ChildrenRepository _childrenRepository = ChildrenRepository();
  late Future<List<ChildrenModel>> _childrenFuture;
  final searchController = TextEditingController();
  String searchQuery = '';

  // 2025 Design Trends with Glassmorphism, Neumorphism, and Dynamic Colors
  final Color primaryColor = Colors.blue[700]!;
  final Color secondaryColor = Colors.blue[200]!;
  final Color accentColor = Colors.orange[400]!;
  final Color backgroundColor = Colors.grey[50]!;
  final Color surfaceColor = Colors.white;
  final Color textPrimaryColor = Colors.grey[900]!;
  final Color textSecondaryColor = Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _childrenRepository.getAllChildren();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Children",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                setState(() {
                  _childrenFuture = _childrenRepository.getAllChildren();
                });
              },
              tooltip: "Refresh data",
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery
                .of(context)
                .padding
                .top + 8),
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<ChildrenModel>>(
                future: _childrenFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final childrenList = snapshot.data!;
                  // Apply search filter
                  final filteredList = searchQuery.isEmpty
                      ? childrenList
                      : childrenList
                      .where((child) =>
                      child.fullName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  if (filteredList.isEmpty) {
                    return _buildNoResults();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildChildCard(filteredList[index], context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: secondaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: "Search children...",
              hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: textSecondaryColor.withOpacity(0.6)),
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    searchQuery = '';
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Loading children data...",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48,
                  color: Colors.red[400]),
            ),
            SizedBox(height: 24),
            Text(
              "Unable to load data",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _childrenFuture = _childrenRepository.getAllChildren();
                });
              },
              icon: Icon(Icons.refresh_rounded),
              label: Text("Try Again", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_care_rounded,
                size: 64,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "No children available",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Add a child to get started",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textSecondaryColor,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Add child functionality
              },
              icon: Icon(Icons.add_rounded),
              label: Text("Add Child", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Try a different search term",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(ChildrenModel child, BuildContext context) {
    // Parse DOB and calculate age
    DateTime dob;
    try {
      final parts = child.dob.split('/');
      dob = DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      dob = DateTime.now();
    }

    final currentDate = DateTime.now();
    final ageInYears = currentDate
        .difference(dob)
        .inDays ~/ 365;
    final ageInMonths = currentDate
        .difference(dob)
        .inDays ~/ 30;

    // Display age in years if above 1, otherwise in months
    final ageText = ageInYears >= 1
        ? "$ageInYears ${ageInYears == 1 ? 'year' : 'years'}"
        : "$ageInMonths ${ageInMonths == 1 ? 'month' : 'months'}";

    // Check for upcoming birthday
    final nextBirthday = DateTime(currentDate.year, dob.month, dob.day);
    final daysToBirthday = nextBirthday.isBefore(currentDate)
        ? DateTime(currentDate.year + 1, dob.month, dob.day)
        .difference(currentDate)
        .inDays
        : nextBirthday
        .difference(currentDate)
        .inDays;

    final hasBirthdaySoon = daysToBirthday <= 7;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: secondaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: secondaryColor.withOpacity(0.2),
            highlightColor: secondaryColor.withOpacity(0.1),
            onTap: () async {
              // bool? result = await Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) =>
              //       CreateVaccineRecordScreen(childId: child.id ?? 0)),
              // );
              //
              // if (result == true) {
              //   setState(() {
              //     _childrenFuture = _childrenRepository.getAllChildren();
              //   });
              // }
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with birthday indicator
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        // Reduced from 80
                        height: 70,
                        // Reduced from 80
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.7),
                              secondaryColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(33),
                              child: Image.network(
                                child.avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return CircleAvatar(
                                    radius: 33,
                                    backgroundColor: secondaryColor.withOpacity(
                                        0.3),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 35,
                                      color: primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasBirthdaySoon)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.cake_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12), // Reduced from 16
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                child.fullName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Modified this row to use Wrap widget to prevent overflow
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.cake_outlined,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              child.dob,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: hasBirthdaySoon
                                    ? accentColor
                                    : textSecondaryColor,
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.child_care_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              ageText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        if (hasBirthdaySoon) ...[
                          SizedBox(height: 10), // Reduced from 12
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            // Reduced horizontal padding
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withOpacity(0.2),
                                  accentColor.withOpacity(0.1)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.celebration_rounded,
                                  size: 14,
                                  color: accentColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Birthday in $daysToBirthday days",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 4), // Added small spacing
                  Container(
                    height: 32, // Reduced from 36
                    width: 32, // Reduced from 36
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          10), // Reduced from 12
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14, // Reduced from 16
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}