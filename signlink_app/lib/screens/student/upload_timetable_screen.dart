import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class UploadTimetableScreen extends StatefulWidget {
  const UploadTimetableScreen({super.key});

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  /// Stores the selected file path (image or document).
  String? _filePath;
  String? _fileName;
  bool _isImage = false;
  bool _isUploading = false;

  // ── Camera / Gallery ──────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,     // compress slightly to save storage
      preferredCameraDevice: CameraDevice.rear,
    );
    if (photo == null) return;
    _applyPick(photo.path, photo.name, isImage: true);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    _applyPick(image.path, image.name, isImage: true);
  }

  // ── File picker (PDF / Excel) ─────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'csv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;
    _applyPick(file.path!, file.name, isImage: false);
  }

  Future<void> _upload() async {
    if (_filePath == null) return;
    setState(() => _isUploading = true);
    try {
      await ApiService.instance.uploadFile(
        '/timetable/upload.php',
        _filePath!,
        'timetable',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timetable uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _applyPick(String path, String name, {required bool isImage}) {
    setState(() {
      _filePath = path;
      _fileName = name;
      _isImage = isImage;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $name'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Upload Timetable')),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Your Timetable',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Upload your academic timetable so we can match you with available interpreters for your classes.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),

              // ── Drop zone / Preview ─────────────────────────────────────
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _filePath != null
                        ? AppColors.success.withValues(alpha: 0.05)
                        : AppColors.inputFill,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(
                      color: _filePath != null
                          ? AppColors.success
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: _filePath != null && _isImage
                      // Show captured/selected image preview
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLG - 2),
                          child: Image.file(
                            File(_filePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _filePath != null
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_file_rounded,
                              size: 48,
                              color: _filePath != null
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _filePath != null
                                  ? _fileName!
                                  : 'Tap to select PDF or Excel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _filePath != null
                                    ? AppColors.success
                                    : AppColors.primary,
                                fontSize: 15,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _filePath != null
                                  ? 'Ready to upload'
                                  : 'PDF, Excel, or CSV accepted',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Camera / Gallery options ────────────────────────────────
              const Text(
                'Or capture with:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OptionButton(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: _pickFromGallery,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_filePath != null)
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.check_rounded,
                  isLoading: _isUploading,
                  onPressed: _isUploading ? null : _upload,
                ),
            ],
          ),
        ),
      );
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OptionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
        ),
      );
}
