import 'dart:io' show File;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/theme_provider.dart';
import '../../utils/user_facing_error.dart';

class EditProfileScreen extends StatefulWidget {
  @visibleForTesting
  static FirebaseAuth Function() defaultAuth = () => FirebaseAuth.instance;

  @visibleForTesting
  static FirebaseStorage Function() defaultStorage = () =>
      FirebaseStorage.instance;

  @visibleForTesting
  static ImagePicker Function() defaultPicker = () => ImagePicker();

  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ImagePicker picker;

  EditProfileScreen({
    super.key,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    ImagePicker? picker,
  }) : auth = auth ?? defaultAuth(),
       storage = storage ?? defaultStorage(),
       picker = picker ?? defaultPicker();

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();

  XFile? _picked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.auth.currentUser;
    _nameController.text = (user?.displayName ?? '').trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final x = await widget.picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (!mounted) return;
    if (x != null) setState(() => _picked = x);
  }

  Future<String?> _uploadPhoto({
    required String uid,
    required XFile file,
  }) async {
    final ref = widget.storage.ref().child('profile_photos/$uid.jpg');
    final uploadTask = ref.putFile(File(file.path));
    await uploadTask.timeout(const Duration(seconds: 30));
    return await ref.getDownloadURL();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final authProvider = context.read<app_auth.AuthProvider>();
      final user = widget.auth.currentUser;
      if (user == null) return;

      final newName = _nameController.text.trim();
      String? photoUrl;
      if (_picked != null) {
        photoUrl = await _uploadPhoto(uid: user.uid, file: _picked!);
      }

      await authProvider.updateProfile(
        displayName: newName.isEmpty ? null : newName,
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            toUserFriendlyMessage(
              e,
              l10n: l10n,
              fallback: l10n.editProfileSaveFailed,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final user = widget.auth.currentUser;
    final existingPhoto = user?.photoURL;

    ImageProvider? avatar;
    if (_picked != null) {
      avatar = FileImage(File(_picked!.path));
    } else if (existingPhoto != null && existingPhoto.isNotEmpty) {
      avatar = NetworkImage(existingPhoto);
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        title: Text(
          l10n.editProfileTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(l10n),
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                    ),
                  )
                : Text(
                    l10n.actionSave,
                    style: TextStyle(
                      color: theme.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: theme.isDarkMode
                        ? Colors.white12
                        : Colors.black12,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? Icon(
                            Icons.person,
                            size: 54,
                            color: theme.accentOrange,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _saving ? null : _pickPhoto,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.accentOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.editProfileName,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.authFieldName,
                filled: true,
                fillColor: theme.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.editProfileFootnote,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
