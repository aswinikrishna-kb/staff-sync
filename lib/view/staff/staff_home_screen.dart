import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/dashboard_card.dart';
import 'package:staff_sync/view/auth/login_screen.dart';
import 'package:staff_sync/view/staff/attendance_screen.dart';
import 'package:staff_sync/view/staff/my_attendance.dart';
import 'package:staff_sync/view/staff/profile_screen.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';

import 'apply_leave_screen.dart';
import 'my_leave_screen.dart';
import 'my_salary_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staff Dashboard',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            DashboardCard(
              title: "Attendance",
              icon: Icons.fingerprint,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: 'My Attendance',
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyAttendanceScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "Apply Leave",
              icon: Icons.event_note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyLeaveScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "My Leave",
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyLeaveScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "My Salary",
              icon: Icons.currency_rupee,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MySalaryScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "Profile",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "Logout",
              icon: Icons.logout,
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
