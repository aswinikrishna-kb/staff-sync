import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../viewmodel/leave_viewmodel.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final staffNameController = TextEditingController();
  final reasonController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          staffNameController.text = doc.data()?['username'] ?? "";
        });
      }
    }
  }

  @override
  void dispose() {
    staffNameController.dispose();
    reasonController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveVM = Provider.of<LeaveViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Leave"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              controller: staffNameController,
              hint: "Staff Name",
              icon: Icons.person,
              enabled: false, // Locked to the registered username
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: reasonController,
              hint: "Reason",
              icon: Icons.edit_note,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: fromDateController,
              hint: "From Date",
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: toDateController,
              hint: "To Date",
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 30),
            leaveVM.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    title: "APPLY LEAVE",
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      if (reasonController.text.isEmpty || 
                          fromDateController.text.isEmpty || 
                          toDateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields")),
                        );
                        return;
                      }

                      await leaveVM.applyLeave(
                        staffId: user.email ?? user.uid,
                        staffName: staffNameController.text.trim(),
                        reason: reasonController.text.trim(),
                        fromDate: fromDateController.text.trim(),
                        toDate: toDateController.text.trim(),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Leave Applied Successfully",
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
