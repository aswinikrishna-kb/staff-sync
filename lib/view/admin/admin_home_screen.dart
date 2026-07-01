import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/dashboard_card.dart';
import 'package:staff_sync/view/admin/add_staff_screen.dart';
import 'package:staff_sync/view/admin/attendance_list_screen.dart';
import 'package:staff_sync/view/admin/leave_list_screen.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import '../auth/login_screen.dart';
import 'salary_list_screen.dart';
import 'staff_list_screen.dart';

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
    // Native way to get yyyy-MM-dd without intl package
    String today = DateTime.now().toIso8601String().split('T')[0];

    return AppScaffold(
      title: 'Admin Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Section - Synchronized Peacock Theme but distinct from buttons
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Staff',
                  stream: FirebaseFirestore.instance.collection('staffs').snapshots(),
                  icon: Icons.people_outline,
                  iconColor: AppColors.peacockDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'Present Today',
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('date', isEqualTo: today)
                      .where('status', isEqualTo: 'Present')
                      .snapshots(),
                  icon: Icons.assignment_turned_in_outlined,
                  iconColor: AppColors.peacockDark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Pending Leave',
                  stream: FirebaseFirestore.instance
                      .collection('leave')
                      .where('status', isEqualTo: 'Pending')
                      .snapshots(),
                  icon: Icons.history_edu_outlined,
                  iconColor: AppColors.peacockDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'Salary Records',
                  stream: FirebaseFirestore.instance.collection('salary').snapshots(),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.peacockDark,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 15),
              child: Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.peacockDark,
                    ),
              ),
            ),
            // Menu Grid - Uses the primary gradient buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                      MaterialPageRoute(builder: (_) => const AddStaffScreen()),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Staff List',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffListScreen()),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Attendance',
                  icon: Icons.calendar_month,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Leave',
                  icon: Icons.event_note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaveListScreen()),
                    );
                  },
                ),
                DashboardCard(
                  title: "Salary",
                  icon: Icons.currency_rupee,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SalaryListScreen()),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required Stream<QuerySnapshot> stream,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.peacockLight,
          borderRadius: BorderRadius.circular(08),
          // Subtle border and shadow to match the peacock theme but remain clean
          border: Border.all(color: AppColors.peacockLight.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.peacockDark.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';
                return Text(
                  count,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.black54,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
