import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/view/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearOfficeData(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;

    try {
      // 1. Delete Staffs linked to this admin
      var staffQuery = await firestore
          .collection('staffs')
          .where('adminUid', isEqualTo: adminUid)
          .get();
      for (var doc in staffQuery.docs) {
        await doc.reference.delete();
      }

      // 2. Delete Attendance linked to this admin
      var attendanceQuery = await firestore
          .collection('attendance')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in attendanceQuery.docs) {
        await doc.reference.delete();
      }

      // 3. Delete Leave linked to this admin
      var leaveQuery = await firestore
          .collection('leave')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in leaveQuery.docs) {
        await doc.reference.delete();
      }

      // 4. Delete Salary linked to this admin
      var salaryQuery = await firestore
          .collection('salary')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in salaryQuery.docs) {
        await doc.reference.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Office data cleared successfully. Admin account is still active.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error clearing data: $e")),
        );
      }
    }
  }

  Future<void> _deleteAdminAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final adminUid = user.uid;

    try {
      // 1. Clear all office data first
      var staffQuery = await FirebaseFirestore.instance
          .collection('staffs')
          .where('adminUid', isEqualTo: adminUid)
          .get();
      for (var doc in staffQuery.docs) { await doc.reference.delete(); }

      var attQuery = await FirebaseFirestore.instance
          .collection('attendance')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in attQuery.docs) { await doc.reference.delete(); }

      var leaveQuery = await FirebaseFirestore.instance
          .collection('leave')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in leaveQuery.docs) { await doc.reference.delete(); }

      var salQuery = await FirebaseFirestore.instance
          .collection('salary')
          .where('officeId', isEqualTo: adminUid)
          .get();
      for (var doc in salQuery.docs) { await doc.reference.delete(); }

      // 2. Delete user record from 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(adminUid).delete();

      // 3. Delete Firebase Auth account
      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account and data deleted permanently.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deletion failed. Please logout and login again to delete your account for security reasons."),
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Office Data"),
        content: const Text("This will delete all staff, attendance, and salary records for your office. Your Admin login will NOT be deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearOfficeData(context);
            },
            child: const Text("CLEAR ALL STAFF DATA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account Permanently"),
        content: const Text("WARNING: This will delete your admin account and ALL associated office data. This action is irreversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAdminAccount(context);
            },
            child: const Text("DELETE MY ACCOUNT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Settings",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Clear Staff Data Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cleaning_services, color: Colors.orange),
              ),
              title: const Text("Clear Office Data", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Delete staff, attendance, and salary records"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClearDataDialog(context),
            ),
          ),
          
          const SizedBox(height: 10),

          // Delete Admin Account Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_remove, color: Colors.redAccent),
              ),
              title: const Text("Delete My Account", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              subtitle: const Text("Permanently delete admin account and all data"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
