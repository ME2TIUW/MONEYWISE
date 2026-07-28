import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_wise/data/aiService/openRouterService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_wise/data/billparserServices/billParser_services.dart';
import 'package:money_wise/data/imageServices/image_service.dart';
import 'package:money_wise/data/ocrServices/ocr_service.dart';
import 'package:money_wise/viewmodels/auth/login_viewmodel.dart';
import 'package:money_wise/viewmodels/auth/register_viewmodel.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/viewmodels/theme/theme_viewmodel.dart';
import 'package:money_wise/viewmodels/moni/moni_viewmodel.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';
import 'package:money_wise/viewmodels/ocr/scan_bill.viewModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_wise/firebase_options.dart';
import 'package:money_wise/views/moni/moni_screen.dart';
import 'package:money_wise/views/history/history_screen.dart';
import 'package:money_wise/views/home/home_screen.dart';
import 'package:money_wise/views/auth/login_screen.dart';
import 'package:money_wise/views/auth/register_screen.dart';
import 'package:money_wise/views/navigation/main_wrapper.dart';
import 'package:money_wise/views/onboarding/initial_setup_screen.dart';
import 'package:money_wise/views/profile/change_password_screen.dart';
import 'package:money_wise/views/profile/profile_screen.dart';
import 'package:money_wise/views/transaction/transaction_screen.dart';
import 'package:money_wise/views/ocr/scan_bill.page.dart';
import 'package:money_wise/views/auth/auth_wrapper.dart';
import 'package:money_wise/data/services/global_navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await UserService()
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => FinanceViewModel()),
        ChangeNotifierProvider(create: (_) => MoniViewModel()),
        ChangeNotifierProvider(
          create: (_) => ScanBillViewModel(
            ImagePickerService(),
            OcrService(),
            ReceiptParser(),
            OpenRouterService(dotenv.env['OPENROUTER_API_KEY'] ?? ''),
          ),
        ),

        ChangeNotifierProxyProvider4<
          RegisterViewModel,
          LoginViewModel,
          FinanceViewModel,
          MoniViewModel,
          ProfileViewModel
        >(
          create: (_) => ProfileViewModel(),
          update: (context, reg, login, fin, moni, profile) {
            return profile!..updateDependencies(reg, login, fin, moni);
          },
        ),
      ],
      child: const MoneyWiseApp(),
    ),
  );
}

class MoneyWiseApp extends StatelessWidget {
  const MoneyWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeViewModel>(
          builder: (context, themeViewModel, _) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              builder: FToastBuilder(),
              debugShowCheckedModeBanner: false,
              title: 'Money Wise',
              themeMode: themeViewModel.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1F40AF),
                  primary: const Color(0xFF1F40AF),
                  brightness: Brightness.light,
                  surface: const Color(0xFFF8F9FA),
                ),
                textTheme: GoogleFonts.interTextTheme(
                  ThemeData.light().textTheme,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1F40AF),
                  primary: const Color(0xFF1F40AF),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF121212),
                ),
                textTheme: GoogleFonts.interTextTheme(
                  ThemeData.dark().textTheme,
                ),
              ),

              home: const AuthWrapper(),

              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/initial-setup': (context) => const InitialSetup(),
                '/main-wrapper': (context) => const MainWrapper(),
                '/home': (context) => const HomeScreen(),
                '/profile': (context) => const ProfileScreen(),
                '/history': (context) => const HistoryScreen(),
                '/transaction': (context) => const TransactionScreen(),
                '/moni': (context) => const MoniScreen(),
                '/scan-bill': (context) => const ScanBillPage(),
                '/change-password': (_) => const ChangePasswordScreen(),
              },
              // initialRoute: '/login',
            );
          },
        );
      },
    );
  }
}
