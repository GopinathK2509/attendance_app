import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/core/themes/user_notifier.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/domain/repositories/user/attendance_list_screen.dart';
import 'package:mobile_attendance_application/domain/repositories/user/edit_profile_screen.dart';
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

class UserSettingsScreen extends StatefulWidget {
  final UserModel user;
  final ValueNotifier<String?> profileImageUrl;

  const UserSettingsScreen({
    required this.user,
    required this.profileImageUrl,
    super.key,
  });

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  File? _selectedImage;
  bool isUploading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> uploadPhoto() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    final fileSize = await _selectedImage!.length();
    if (fileSize > 4 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image size must be under 4 MB")),
      );
      return;
    }

    setState(() => isUploading = true);

    final uri = Uri.parse(
      "https://trainerattendence-backed.onrender.com/api/users/upload-photo/${widget.user.userId}",
    );

    var request = http.MultipartRequest("POST", uri);
    final bytes = await _selectedImage!.readAsBytes();
    final fileName = _selectedImage!.path.split('/').last;

    request.files.add(
      http.MultipartFile.fromBytes('photo', bytes, filename: fileName),
    );

    try {
      var response = await request.send();
      await response.stream.bytesToString();

      setState(() => isUploading = false);

      if (response.statusCode == 200) {
        // widget.profileImageUrl.value =
        //     "https://trainerattendence-backed.onrender.com/api/users/photo/${widget.user.userId}";

        final newUrl =
            "https://trainerattendence-backed.onrender.com/api/users/photo/${widget.user.userId}?t=${DateTime.now().millisecondsSinceEpoch}";

        widget.profileImageUrl.value = newUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully")),
        );
        setState(() => _selectedImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (kDebugMode) print("Upload error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload error: $e")));
    }
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFF9E7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: widget.profileImageUrl,
                builder: (context, imageUrl, _) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (imageUrl != null ? NetworkImage(imageUrl) : null),
                    child: (_selectedImage == null && imageUrl == null)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.deepPurple,
                          )
                        : null,
                  );
                },
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ValueListenableBuilder<UserModel?>(
            valueListenable: globalUser,
            builder: (context, user, _) {
              return Text(
                user?.name ?? widget.user.name ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const SizedBox(height: 4),
          Text(
            widget.user.email ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton.icon(
                  onPressed: uploadPhoto,
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 12),
            _buildSettingsOption(
              icon: Icons.person,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      profileImageUrl: widget.profileImageUrl,
                      name: widget.user.name ?? '',
                      email: widget.user.email ?? '',
                      userId: widget.user.userId ?? '',
                    ),
                  ),
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {},
            ),
            if (widget.user.role == "user")
              _buildSettingsOption(
                icon: Icons.history,
                title: "Attendance History",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceListScreen(user: widget.user),
                    ),
                  );
                },
              ),
            if (widget.user.role == "admin") ...[
              _buildSettingsOption(
                icon: Icons.group,
                title: "Manage Users",
                onTap: () {},
              ),
              _buildSettingsOption(
                icon: Icons.bar_chart,
                title: "Reports & Dashboard",
                onTap: () {},
              ),
              _buildSettingsOption(
                icon: Icons.history,
                title: "All Attendance Records",
                onTap: () {},
              ),
            ],
            _buildSettingsOption(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.red,
              onTap: () => LogoutDialog.show(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
