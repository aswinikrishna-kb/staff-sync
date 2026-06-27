import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  Future<void> _punchIn(BuildContext context) async {
    final attendanceVM = context.read<AttendanceViewModel>();

    await attendanceVM.punchIn();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance Marked Successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Attendance',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff ID', style: textTheme.titleMedium),
            Text(attendanceVM.currentStaffId, style: textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text('Staff Name', style: textTheme.titleMedium),
            Text(attendanceVM.currentStaffName, style: textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text('Date', style: textTheme.titleMedium),
            Text(attendanceVM.currentDate, style: textTheme.bodyLarge),
            const SizedBox(height: 40),
            attendanceVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    title: 'PUNCH IN',
                    onTap: () => _punchIn(context),
                  ),
          ],
        ),
      ),
    );
  }
}
