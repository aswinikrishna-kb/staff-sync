import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/theme/app_theme.dart';
import 'package:staff_sync/firebase_options.dart';
import 'package:staff_sync/view/auth/login_screen.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/viewmodel/leave_viewmodel.dart';
import 'package:staff_sync/viewmodel/staff_viewmodel.dart';
import 'package:staff_sync/viewmodel/salary_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StaffViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
        ChangeNotifierProvider(create: (_) => LeaveViewModel()),
       // ChangeNotifierProvider(create: (_) => SalaryViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const LoginScreen(),
      ),
    );
  }
}
