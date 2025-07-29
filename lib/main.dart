import 'package:b2v_admin_panel/pages/biometric_or_manual_page.dart';
import 'package:b2v_admin_panel/pages/home_page.dart';
import 'package:b2v_admin_panel/pages/regular_login_page.dart';
import 'package:b2v_admin_panel/provider/attendance_provider.dart';
import 'package:b2v_admin_panel/provider/birthday_provider.dart';
import 'package:b2v_admin_panel/provider/employee_summary_provider.dart';
import 'package:b2v_admin_panel/provider/leave_manage_provider.dart';
import 'package:b2v_admin_panel/provider/leave_provider.dart';
import 'package:b2v_admin_panel/provider/report_provider.dart';
import 'package:b2v_admin_panel/provider/task_provider.dart';
import 'package:b2v_admin_panel/provider/user_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:b2v_admin_panel/service/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_flow.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterNativeSplash.remove();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BirthdayProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => LeaveManageProvider()..fetchLeaves()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeSummaryProvider()),
        // Add other providers here as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face ID Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthFlow(),
      debugShowCheckedModeBanner: false,
    );
  }
}

