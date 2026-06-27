import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../viewmodel/leave_viewmodel.dart';

class ApplyLeaveScreen extends StatelessWidget {
  ApplyLeaveScreen({super.key});

  final staffNameController = TextEditingController();
  final reasonController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

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

                      await leaveVM.applyLeave(
                        staffId: user.uid,
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
