import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';

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
  String? _officeId;

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
          _officeId = doc.data()?['officeId'];
        });
      }
    }
  }

  // Universal date picker method
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // Allows past or future depending on needs
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.peacockDark,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
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

    return AppScaffold(
      title: "Apply Leave",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Registered username (Read-only)
            CustomTextField(
              controller: staffNameController,
              hint: "Staff Name",
              icon: Icons.person,
              enabled: false,
            ),
            const SizedBox(height: 15),
            
            CustomTextField(
              controller: reasonController,
              hint: "Reason for leave",
              icon: Icons.edit_note,
            ),
            const SizedBox(height: 15),

            // From Date Picker
            InkWell(
              onTap: () => _selectDate(context, fromDateController),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: fromDateController,
                  hint: "From Date",
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // To Date Picker
            InkWell(
              onTap: () => _selectDate(context, toDateController),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: toDateController,
                  hint: "To Date",
                  icon: Icons.calendar_month,
                ),
              ),
            ),
            const SizedBox(height: 30),

            leaveVM.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : CustomButton(
                    title: "SUBMIT REQUEST",
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      if (reasonController.text.isEmpty || 
                          fromDateController.text.isEmpty || 
                          toDateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select all dates and reason")),
                        );
                        return;
                      }

                      await leaveVM.applyLeave(
                        staffId: user.email!.toLowerCase(),
                        staffName: staffNameController.text.trim(),
                        reason: reasonController.text.trim(),
                        fromDate: fromDateController.text.trim(),
                        toDate: toDateController.text.trim(),
                        officeId: _officeId ?? "",
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Leave Request Submitted")),
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
