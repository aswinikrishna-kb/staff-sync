import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/dashboard_card.dart';
import 'package:staff_sync/view/admin/add_staff_screen.dart';
import 'package:staff_sync/view/admin/attendance_list_screen.dart';
import 'package:staff_sync/view/admin/leave_list_screen.dart';
import 'package:staff_sync/view/admin/staff_list_screen.dart';
import 'package:staff_sync/view/auth/login_screen.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';

import 'add_salary_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
      title: 'Admin Dashboard',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            DashboardCard(
              title: 'Add Staff',
              icon: Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddStaffScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: 'Staff List',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StaffListScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: 'Attendance',
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceListScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: 'Leave',
              icon: Icons.event_note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LeaveListScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: "Salary",
              icon: Icons.currency_rupee,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSalaryScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              title: 'Logout',
              icon: Icons.logout,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
