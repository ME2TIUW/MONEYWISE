// import 'package:animations/animations.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:money_wise/views/moni/moni_screen.dart';
// import 'package:money_wise/views/history/history_screen.dart';
// import 'package:money_wise/views/home/home_screen.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:money_wise/views/profile/profile_screen.dart';

// class MainWrapper extends StatefulWidget {
//   const MainWrapper({super.key});

//   @override
//   State<MainWrapper> createState() => _MainWrapperState();
// }

// class _MainWrapperState extends State<MainWrapper> {
//   int _currentIndex = 0;

//   //screens
//   // final List<Widget> _pages = [
//   //   const HomeScreen(),
//   //   const HistoryScreen(),
//   //   MoniScreen(isActive: _currentIndex == 2),
//   //   const ProfileScreen(),
//   // ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       body: PageTransitionSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
//           return FadeThroughTransition(
//             animation: primaryAnimation,
//             secondaryAnimation: secondaryAnimation,
//             child: child,
//           );
//         },
//         child: IndexedStack(
//           key: ValueKey<int>(_currentIndex),
//           index: _currentIndex,
//           children: [
//             const HomeScreen(),
//             const HistoryScreen(),
//             MoniScreen(isActive: _currentIndex == 2),
//             const ProfileScreen(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           selectedItemColor: Theme.of(context).primaryColor,
//           unselectedItemColor: Colors.grey.shade500,
//           selectedFontSize: 12.sp,
//           unselectedFontSize: 12.sp,
//           iconSize: 20.r,
//           items: [
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4.h),
//                 child: const FaIcon(FontAwesomeIcons.house),
//               ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4.h),
//                 child: const FaIcon(FontAwesomeIcons.receipt),
//               ),
//               label: 'History',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4.h),
//                 child: const Icon(Icons.auto_awesome),
//               ),
//               label: 'Moni AI',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4.h),
//                 child: const FaIcon(FontAwesomeIcons.user),
//               ),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Transform.translate(
//         offset: const Offset(0, -10),
//         child: FloatingActionButton(
//           heroTag: 'main_wrapper_fab',
//           onPressed: () {
//             Navigator.pushNamed(context, '/scan-bill');
//           },
//           backgroundColor: Theme.of(context).primaryColor,
//           elevation: 2,
//           shape: const CircleBorder(),
//           child: Icon(
//             Icons.qr_code_scanner_rounded,
//             color: Colors.white,
//             size: 30.r,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:money_wise/views/moni/moni_screen.dart';
import 'package:money_wise/views/history/history_screen.dart';
import 'package:money_wise/views/home/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/views/profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const HistoryScreen(),
            MoniScreen(isActive: _currentIndex == 2),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurfaceVariant,
                selectedFontSize: 12.sp,
                unselectedFontSize: 12.sp,
                iconSize: 20.r,
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: const FaIcon(FontAwesomeIcons.house),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: const FaIcon(FontAwesomeIcons.receipt),
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: const Icon(Icons.auto_awesome),
                    ),
                    label: 'Moni AI',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: const FaIcon(FontAwesomeIcons.user),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardOpen
          ? null
          : Transform.translate(
              offset: const Offset(0, -10),
              child: FloatingActionButton(
                heroTag: 'main_wrapper_fab',
                onPressed: () {
                  Navigator.pushNamed(context, '/scan-bill');
                },
                backgroundColor: colorScheme.primary,
                elevation: 2,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.document_scanner_rounded,
                  color: isDark ? Colors.white : colorScheme.onPrimary,
                  size: 30.r,
                ),
              ),
            ),
    );
  }
}
