import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAttendance() async {
    final attendanceVM = context.read<AttendanceViewModel>();

    await attendanceVM.addAttendance(
      staffId: '001',
      staffName: _nameController.text.trim(),
      date: attendanceVM.currentDate,
      status: 'Present',
      punchInTime: attendanceVM.currentPunchInTime,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();

    return AppScaffold(
      title: 'Mark Attendance',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hint: 'Staff Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            attendanceVM.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    title: 'SAVE',
                    onTap: _saveAttendance,
                  ),
          ],
        ),
      ),
    );
  }
}
