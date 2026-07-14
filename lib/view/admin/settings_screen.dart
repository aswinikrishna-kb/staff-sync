import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/view/auth/login_screen.dart';
import 'package:staff_sync/viewmodel/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteStaffData(BuildContext context, {String? staffEmail, String? staffName}) async {
    final firestore = FirebaseFirestore.instance;
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;

    try {
      // If staffEmail is null, we clear ALL staff data for this office
      bool isAll = staffEmail == null;

      // 1. Delete from 'staffs' collection
      var staffQuery = firestore.collection('staffs').where('adminUid', isEqualTo: adminUid);
      if (!isAll) staffQuery = staffQuery.where('email', isEqualTo: staffEmail);
      
      var staffDocs = await staffQuery.get();
      for (var doc in staffDocs.docs) {
        await doc.reference.delete();
      }

      // 2. Delete from 'users' collection (The actual account link)
      var usersQuery = firestore.collection('users').where('officeId', isEqualTo: adminUid).where('role', isEqualTo: 'staff');
      if (!isAll) usersQuery = usersQuery.where('email', isEqualTo: staffEmail);
      
      var userDocs = await usersQuery.get();
      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }

      // 3. Delete Attendance
      var attQuery = firestore.collection('attendance').where('officeId', isEqualTo: adminUid);
      if (!isAll) attQuery = attQuery.where('staffId', isEqualTo: staffEmail);
      var attDocs = await attQuery.get();
      for (var doc in attDocs.docs) { await doc.reference.delete(); }

      // 4. Delete Leaves
      var leaveQuery = firestore.collection('leave').where('officeId', isEqualTo: adminUid);
      if (!isAll) leaveQuery = leaveQuery.where('staffId', isEqualTo: staffEmail);
      var leaveDocs = await leaveQuery.get();
      for (var doc in leaveDocs.docs) { await doc.reference.delete(); }

      // 5. Delete Salary
      var salQuery = firestore.collection('salary').where('officeId', isEqualTo: adminUid);
      if (!isAll) salQuery = salQuery.where('staffId', isEqualTo: staffEmail);
      var salDocs = await salQuery.get();
      for (var doc in salDocs.docs) { await doc.reference.delete(); }

      // 6. Delete Work Updates
      var workQuery = firestore.collection('work_updates').where('officeId', isEqualTo: adminUid);
      if (!isAll) workQuery = workQuery.where('staffId', isEqualTo: staffEmail);
      var workDocs = await workQuery.get();
      for (var doc in workDocs.docs) { await doc.reference.delete(); }

      if (context.mounted) {
        String msg = isAll ? "All staff data cleared." : "Data for $staffName cleared.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Staff Data"),
        content: const Text("This will permanently delete ALL staff records, accounts, attendance, and work logs. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStaffData(context);
            },
            child: const Text("DELETE EVERYTHING", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSpecificDialog(BuildContext context) {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Staff to Delete"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('staffs')
                .where('adminUid', isEqualTo: adminUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var staff = snapshot.data!.docs;
              if (staff.isEmpty) return const Center(child: Text("No staff found."));

              return ListView.builder(
                itemCount: staff.length,
                itemBuilder: (context, index) {
                  var data = staff[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? ""),
                    subtitle: Text(data['email'] ?? ""),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmSpecificDelete(context, data['email'], data['name']);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmSpecificDelete(BuildContext context, String email, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $name?"),
        content: Text("This will wipe all data and account access for $email. Proceed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStaffData(context, staffEmail: email, staffName: name);
            },
            child: const Text("DELETE STAFF", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return AppScaffold(
      title: "Admin Settings",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text("Appearance", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.peacockDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppColors.peacockDark),
              ),
              title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(themeVM.isDarkMode ? "Switch to light theme" : "Switch to dark theme"),
              value: themeVM.isDarkMode,
              activeColor: AppColors.peacock,
              onChanged: (val) => themeVM.toggleTheme(val),
            ),
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text("Data Management", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
          
          // Option 1: Specific Staff
          _buildSettingsCard(
            title: "Delete Specific Staff",
            subtitle: "Wipe data for one specific person",
            icon: Icons.person_remove_outlined,
            color: Colors.orange,
            onTap: () => _showDeleteSpecificDialog(context),
          ),
          
          const SizedBox(height: 12),

          // Option 2: Complete Staff Data
          _buildSettingsCard(
            title: "Clear All Staff Data",
            subtitle: "Wipe everything (Accounts, Logs, Invoices)",
            icon: Icons.auto_delete_outlined,
            color: Colors.redAccent,
            onTap: () => _showClearAllDialog(context),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 30, bottom: 12),
            child: Text("Account Security", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),

          _buildSettingsCard(
            title: "Logout Admin",
            subtitle: "Exit the control panel",
            icon: Icons.logout,
            color: Colors.blue,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
