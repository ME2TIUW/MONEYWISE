import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final ProfileViewModel vm;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
    required this.vm,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isUploading = false;

  Future<void> _handleUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      await widget.vm.uploadProfileImage(widget.imageFile);
      if (!mounted) return;

      ToastService.showSuccess('Profile picture updated!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ToastService.showError('Failed to upload image.');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Preview Image',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.file(widget.imageFile, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Profile Picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
