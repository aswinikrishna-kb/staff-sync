import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/dashboard_card.dart';
import 'package:staff_sync/view/admin/add_staff_screen.dart';
import 'package:staff_sync/view/admin/admin_invoice_list_screen.dart';
import 'package:staff_sync/view/admin/admin_work_log_screen.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/view/admin/attendance_list_screen.dart';
import 'package:staff_sync/view/admin/leave_list_screen.dart';
import 'package:staff_sync/view/admin/salary_list_screen.dart';
import 'package:staff_sync/view/admin/staff_list_screen.dart';
import 'package:staff_sync/view/admin/settings_screen.dart';
import 'package:staff_sync/view/admin/admin_finance_screen.dart';
import '../auth/login_screen.dart';

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
    final String today = DateTime.now().toIso8601String().split('T')[0];
    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;
    final authVM = context.watch<AuthViewModel>();
    final admin = authVM.userModel;

    return AppScaffold(
      title: admin?.companyName ?? "Admin Dashboard",
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.peacockDark),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: AppColors.peacockDark, size: 40),
              ),
              accountName: Text(admin?.companyName ?? "Admin Panel", 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(admin?.email ?? ""),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppColors.peacockDark),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.peacockDark),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROFESSIONAL CLASSIC & COMPACT COMMAND CENTER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.business_center_outlined, color: AppColors.peacockDark, size: 18),
                          SizedBox(width: 8),
                          Text("Office Pulse",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.peacockDark)),
                        ],
                      ),
                      Text(today, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Row 1: Key Metrics (Attendance, Invoices, Leaves)
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _buildCompactMetric(
                          "PRESENT",
                          _getAttendanceFraction(adminUid, today),
                          Colors.blue.shade800,
                        ),
                        _buildDivider(),
                        _buildCompactMetric(
                          "INVOICES",
                          _getCountText(FirebaseFirestore.instance.collection('invoices').where('officeId', isEqualTo: adminUid).where('status', isEqualTo: 'Pending').snapshots()),
                          Colors.purple.shade700,
                        ),
                        _buildDivider(),
                        _buildCompactMetric(
                          "LEAVES",
                          _getCountText(FirebaseFirestore.instance.collection('leave').where('officeId', isEqualTo: adminUid).where('status', isEqualTo: 'Pending').snapshots()),
                          Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.grey[100]),
                  ),

                  // Row 2: Work Logs Progression
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _buildWorkMetric("PROGRAM", Colors.indigo, FirebaseFirestore.instance.collection('work_updates').where('officeId', isEqualTo: adminUid).where('date', isEqualTo: today).where('status', isEqualTo: 'Program').snapshots()),
                        _buildDivider(),
                        _buildWorkMetric("ACTIVE", Colors.orange.shade800, FirebaseFirestore.instance.collection('work_updates').where('officeId', isEqualTo: adminUid).where('date', isEqualTo: today).where('status', isEqualTo: 'Progression').snapshots()),
                        _buildDivider(),
                        _buildWorkMetric("DONE", Colors.teal.shade700, FirebaseFirestore.instance.collection('work_updates').where('officeId', isEqualTo: adminUid).where('date', isEqualTo: today).where('status', isEqualTo: 'Completed').snapshots()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text("Management Hub", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                DashboardCard(title: 'Financials', icon: Icons.pie_chart_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceScreen()))),
                DashboardCard(title: 'Activity Logs', icon: Icons.assignment_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWorkLogScreen()))),
                DashboardCard(title: 'Staff Directory', icon: Icons.group_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffListScreen()))),
                DashboardCard(title: 'Attendance', icon: Icons.calendar_today_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen()))),
                DashboardCard(title: 'Leave Apps', icon: Icons.event_note_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveListScreen()))),
                DashboardCard(title: "Invoices", icon: Icons.receipt_long_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminInvoiceListScreen()))),
                DashboardCard(title: "Add Staff", icon: Icons.person_add_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffScreen()))),
                DashboardCard(title: 'Logout', icon: Icons.logout_outlined, onTap: () => _logout(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPACT UI HELPERS ---

  Widget _buildDivider() => VerticalDivider(width: 1, thickness: 1, color: Colors.grey[100]);

  Widget _buildCompactMetric(String label, Widget valueWidget, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildWorkMetric(String label, Color color, Stream<QuerySnapshot> stream) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color.withOpacity(0.6), letterSpacing: 0.5)),
          const SizedBox(height: 2),
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';
              return Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color));
            },
          ),
        ],
      ),
    );
  }

  Widget _getAttendanceFraction(String? adminUid, String today) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('staffs').where('adminUid', isEqualTo: adminUid).snapshots(),
      builder: (context, totalSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('attendance').where('officeId', isEqualTo: adminUid).where('date', isEqualTo: today).where('status', isEqualTo: 'Present').snapshots(),
          builder: (context, presentSnapshot) {
            String total = totalSnapshot.hasData ? totalSnapshot.data!.docs.length.toString() : '0';
            String present = presentSnapshot.hasData ? presentSnapshot.data!.docs.length.toString() : '0';
            return Text("$present / $total", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87));
          },
        );
      },
    );
  }

  Widget _getCountText(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';
        return Text(count, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87));
      },
    );
  }
}
