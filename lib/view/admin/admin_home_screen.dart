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
    String today = DateTime.now().toIso8601String().split('T')[0];

    return AppScaffold(
      title: 'Admin Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Section - Styled as "Standard Filter Bar"
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Staff',
                  stream: FirebaseFirestore.instance.collection('staffs').snapshots(),
                  icon: Icons.people_outline,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: 'Present Today',
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('date', isEqualTo: today)
                      .where('status', isEqualTo: 'Present')
                      .snapshots(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green.shade700,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Pending Leave',
                  stream: FirebaseFirestore.instance
                      .collection('leave')
                      .where('status', isEqualTo: 'Pending')
                      .snapshots(),
                  icon: Icons.pending_actions,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: 'Salary Records',
                  stream: FirebaseFirestore.instance.collection('salary').snapshots(),
                  icon: Icons.payments_outlined,
                  color: Colors.purple.shade700,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 15),
              child: Text(
                "Management",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.peacockDark,
                    ),
              ),
            ),
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
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.peacockLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.peacockDark), // Same as Filter Bar
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.peacock,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.peacockDark, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: stream,
                    builder: (context, snapshot) {
                      String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';
                      return Text(
                        count,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.peacockDark,
                        ),
                      );
                    },
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
