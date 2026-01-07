import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/core/themes/user_notifier.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final ValueNotifier<String?> profileImageUrl;
  final String name;
  final String email;
  final String userId;

  const EditProfileScreen({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.email,
    required this.userId,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  File? _selectedImage;
  bool _isUploading = false;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: globalUser.value?.name ?? widget.name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose an image first")),
      );
      return;
    }

    final fileSize = await _selectedImage!.length();
    if (fileSize > 4 * 1024 * 1024) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Image must be under 4 MB")));
      return;
    }

    setState(() => _isUploading = true);

    final uri = Uri.parse(
      "https://trainerattendence-backed.onrender.com/api/users/upload-photo/${widget.userId}",
    );

    try {
      final req = http.MultipartRequest('POST', uri);
      final bytes = await _selectedImage!.readAsBytes();
      final filename = _selectedImage!.path.split('/').last;

      req.files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: filename),
      );

      final streamed = await req.send();
      final respStr = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final newUrl =
            "https://trainerattendence-backed.onrender.com/api/users/photo/${widget.userId}?t=${DateTime.now().millisecondsSinceEpoch}";

        widget.profileImageUrl.value = newUrl;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully")),
        );

        setState(() => _selectedImage = null);
      } else {
        String message = "Upload failed: ${streamed.statusCode}";
        try {
          final parsed = jsonDecode(respStr);
          if (parsed is Map && parsed['message'] != null) {
            message = parsed['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (kDebugMode) print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() => _isSavingName = true);

    final uri = Uri.parse(
      "https://trainerattendence-backed.onrender.com/api/users/update-name",
    );

    final body = jsonEncode({"userId": widget.userId, "newName": newName});

    try {
      final resp = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);

        final newName = responseData['updatedName'] as String;
        if (globalUser.value == null) {
          globalUser.value = UserModel(userId: widget.userId, name: newName);
        } else {
          globalUser.value = globalUser.value!.copyWith(name: newName);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', newName);

        globalUser.notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Name updated successfully',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        String message = "Update failed: ${resp.statusCode}";
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map && decoded['message'] != null)
            message = decoded['message'];
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (kDebugMode) print("Name update error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSavingName = false);
    }
  }

  // void _goToChangePassword() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(builder: (_) => const _ChangePasswordPlaceholder()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.white.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: widget.profileImageUrl,
                          builder: (context, imageUrl, _) {
                            ImageProvider? provider;
                            if (_selectedImage != null) {
                              provider = FileImage(_selectedImage!);
                            } else if (imageUrl != null) {
                              provider = NetworkImage(imageUrl);
                            } else {
                              provider = null;
                            }

                            return CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.white,
                              backgroundImage: provider,
                              child: provider == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 64,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),

                      Positioned(
                        right: MediaQuery.of(context).size.width / 2 - 64 - 12,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: 1,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full name",
                              labelStyle: const TextStyle(
                                color: Colors.deepPurple,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.deepPurple,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Name cannot be empty';
                              if (v.trim().length < 2)
                                return 'Enter a valid name';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: TextEditingController(text: widget.email),
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Email (not editable)",
                            labelStyle: const TextStyle(
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSavingName
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false)
                                          _saveName();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSavingName
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Save Name",
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.9,
                                  ),
                                  side: BorderSide(
                                    color: Colors.deepPurple.withOpacity(0.18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Change Password",
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isUploading ? null : _uploadPhoto,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(
                                  _isUploading
                                      ? "Uploading..."
                                      : "Upload Photo",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_selectedImage != null)
                              OutlinedButton(
                                onPressed: () =>
                                    setState(() => _selectedImage = null),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Cancel"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Tip: Upload a clear profile photo. Name updates will reflect after saving.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

