import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    UserProfile? profile = await UserRepository().getUserProfile();
    setState(() {
      userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfile!.avatar),
            ),
            SizedBox(height: 16),
            Text("👤 Name: ${userProfile!.fullName}"),
            Text("📧 Email: ${userProfile!.email}"),
            Text("🔑 Role: ${userProfile!.role}"),
            Text("📆 Created At: ${userProfile!.createdAt.toLocal()}"),
          ],
        ),
      ),
    );
  }
}
