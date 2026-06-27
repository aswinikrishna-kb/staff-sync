import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_list_card.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/attendance_model.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.read<AttendanceViewModel>();

    return AppScaffold(
      title: 'Attendance List',
      body: StreamBuilder<List<AttendanceModel>>(
        stream: attendanceVM.watchAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendanceList = snapshot.data ?? [];

          if (attendanceList.isEmpty) {
            return const AppEmptyMessage(
              message: 'No Attendance Found',
              icon: Icons.event_busy,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];

              return AppListCard(
                title: attendance.staffName,
                icon: Icons.calendar_today,
                subtitles: [
                  'Date : ${attendance.date}',
                  'Status : ${attendance.status}',
                ],
              );
            },
          );
        },
      ),
    );
  }
}
