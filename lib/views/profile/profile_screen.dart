import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';
import 'package:money_wise/viewmodels/theme/theme_viewmodel.dart';
import 'package:money_wise/views/profile/change_password_screen.dart';
import 'package:money_wise/views/profile/image_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final int value = int.parse(digits);
    final formatted = _fmt.format(value);

    final newOffset =
        formatted.length - (oldValue.text.length - oldValue.selection.end);
    final caret = newOffset.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(value);
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        final vm = context.read<ProfileViewModel>();
        if (vm.user == null) {
          vm.fetchProfile();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24.sp,
            color: isDark
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: vm.isLoading && vm.user == null
          ? _buildSkeletonLoader()
          : vm.user == null
          ? const Center(child: Text('Profile data not found'))
          : RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () async {
                await vm.fetchProfile(isRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildHeader(vm),
                    SizedBox(height: 24.h),
                    _buildInfoCard(vm),
                    SizedBox(height: 12.h),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showEditProfileSheet(context, vm);
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          minimumSize: Size.fromHeight(52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildFinancialAccess(vm),
                    _buildThemeSettings(context),
                    SizedBox(height: 16.h),
                    _buildChangePassword(context),
                    SizedBox(height: 12.h),
                    _buildLogout(vm, context),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ProfileViewModel vm) {
    final user = vm.user!;
    final String rawFirstName = user.name.trim().split(' ').first;
    final String firstName = rawFirstName.isNotEmpty
        ? '${rawFirstName[0].toUpperCase()}${rawFirstName.substring(1).toLowerCase()}'
        : 'User';

    ImageProvider? getImageProvider(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return null;

      if (imagePath.startsWith('data:image')) {
        final base64String = imagePath.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } else if (imagePath.startsWith('http')) {
        return NetworkImage(imagePath);
      }
      return null;
    }

    final imageProvider = getImageProvider(user.profileImageUrl);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceActionSheet(context, vm),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48.r,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        getInitials(user.name),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          firstName,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet(BuildContext context, ProfileViewModel vm) {
    final hasImage = vm.user?.profileImageUrl != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1677FF)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, vm);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1677FF),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, vm);
                },
              ),
              if (hasImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await vm.deleteProfileImage();
                    ToastService.showSuccess('Profile picture removed');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, ProfileViewModel vm) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(
              imageFile: File(pickedFile.path),
              vm: vm,
            ),
          ),
        );
      }
    } catch (e) {
      ToastService.showError('Failed to pick picture');
      debugPrint("Image Picker Error: $e");
    }
  }

  Widget _buildInfoCard(ProfileViewModel vm) {
    final user = vm.user!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          _buildItem('Full Name', user.name),
          _buildDivider(),
          _buildItem('Email', user.email),
          _buildDivider(),
          _buildItem(
            'Monthly Budget',
            user.monthlyBudget != null
                ? formatRupiah(user.monthlyBudget!)
                : '-',
          ),
          _buildDivider(),
          _buildItem('Phone Number', user.phone ?? '-'),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return ListTile(
      title: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  // Widget _buildAIStatus() {
  //   return Container(
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(16.r),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.auto_awesome, color: Colors.blue),
  //         SizedBox(width: 12.w),
  //         const Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'OCR AI STATUS',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               Text('8/10 scan used this month'),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildChangePassword(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        final vm = context.read<ProfileViewModel>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: const ChangePasswordScreen(),
            ),
          ),
        );
      },
      icon: Icon(Icons.lock_outline, color: Colors.white),
      label: Text('Change Password', style: TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: Size.fromHeight(52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildLogout(ProfileViewModel vm, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await vm.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
          ToastService.showSuccess('Sign Out Successful!');
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(52.h),
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildFinancialAccess(ProfileViewModel vm) {
    final allow = vm.user?.allowFinancialAccess ?? false;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: SwitchListTile(
          title: const Text(
            "Allow Moni to access financial data",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          value: allow,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) async {
            await vm.updateFinancialAccess(value);
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  width: 96.r, 
                  height: 96.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 120.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, ProfileViewModel vm) {
    final nameController = TextEditingController(text: vm.user!.name);
    final phoneController = TextEditingController(text: vm.user!.phone ?? '');

    final decimalFormatter = NumberFormat.decimalPattern('id');
    final String formattedInitialBudget = vm.user!.monthlyBudget != null
        ? decimalFormatter.format(vm.user!.monthlyBudget)
        : '';

    final budgetController = TextEditingController(
      text: formattedInitialBudget,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final budgetText = budgetController.text.trim();

                  if (name.isEmpty) {
                    ToastService.showError('Full Name cannot be empty');
                    return;
                  }

                  if (name.length < 3) {
                    ToastService.showError(
                      'Full Name must be at least 3 characters',
                    );
                    return;
                  }

                  if (phone.isEmpty) {
                    ToastService.showError('Phone number cannot be empty');
                    return;
                  }

                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)) {
                    ToastService.showError('Please enter a valid phone number');
                    return;
                  }

                  if (budgetText.isEmpty) {
                    ToastService.showError('Monthly budget cannot be empty');
                    return;
                  }

                  final String cleanBudgetText = budgetText.replaceAll(
                    RegExp(r'\D'),
                    '',
                  );
                  final newMonthlyBudget = double.tryParse(cleanBudgetText);

                  if (newMonthlyBudget == null || newMonthlyBudget <= 0) {
                    ToastService.showError(
                      'Please enter a valid amount greater than 0',
                    );
                    return;
                  }

                  await vm.updateProfile(
                    name: name,
                    phone: phone,
                    newMonthlyBudget: newMonthlyBudget,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ToastService.showSuccess('Profile updated successfully!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    final isDarkMode =
        themeVm.themeMode == ThemeMode.dark ||
        (themeVm.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: SwitchListTile(
          title: const Text(
            "Dark Mode",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          secondary: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
          value: isDarkMode,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) {
            themeVm.toggleTheme(value);
          },
        ),
      ),
    );
  }
}
