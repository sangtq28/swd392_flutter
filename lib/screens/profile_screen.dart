import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Example controllers for the 4 fields
  final TextEditingController _emailController =
  TextEditingController(text: "john.doe@example.com");
  final TextEditingController _phoneController =
  TextEditingController(text: "202 555 0111");
  final TextEditingController _firstNameController =
  TextEditingController(text: "John");
  final TextEditingController _lastNameController =
  TextEditingController(text: "Doe");

  // Example placeholder image
  final String profileImageUrl = "https://picsum.photos/200";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      // Use SingleChildScrollView to allow vertical scrolling if content is tall
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Center + ConstrainedBox to limit max width on large screens
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------- Profile Image (CircleAvatar) --------
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                ),
                const SizedBox(height: 16),

                // -------- Upload / Reset Buttons (stacked vertically) --------
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement photo upload
                        },
                        child: const Text("Upload New Photo"),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement reset
                        },
                        child: const Text("Reset"),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Allowed JPG, GIF or PNG. Max size of 800K",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 24),

                // -------- 4 TextFields in one Column --------
                _buildTextField(
                  label: "Email",
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "First Name",
                  controller: _firstNameController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "Last Name",
                  controller: _lastNameController,
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 24),

                // -------- Save & Cancel Buttons --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Save logic
                      },
                      child: const Text("Save Changes"),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Cancel logic
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget for a labeled TextField
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
