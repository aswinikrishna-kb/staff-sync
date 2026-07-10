import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';
import 'package:staff_sync/model/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();

    return AppScaffold(
      title: 'Daily Attendance',
      body: StreamBuilder<AttendanceModel?>(
        stream: attendanceVM.watchTodayStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final attendance = snapshot.data;
          final bool hasPunchedIn = attendance != null;
          final bool hasPunchedOut = attendance?.punchOutTime.isNotEmpty ?? false;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dynamic Icon based on Status
                  Icon(
                    hasPunchedOut ? Icons.check_circle : (hasPunchedIn ? Icons.timer : Icons.fingerprint),
                    size: 100, 
                    color: hasPunchedOut ? Colors.greenAccent : (hasPunchedIn ? Colors.orangeAccent : Colors.white),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    hasPunchedOut ? "Attendance Completed" : (hasPunchedIn ? "You are Punched In" : "Welcome! Please Punch In"),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Date: ${attendanceVM.currentDate}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  
                  // Display times if they exist
                  if (hasPunchedIn) ...[
                    _buildTimeChip("PUNCH IN", attendance!.punchInTime),
                    const SizedBox(height: 10),
                    if (hasPunchedOut) _buildTimeChip("PUNCH OUT", attendance.punchOutTime),
                    const SizedBox(height: 30),
                  ],

                  // Action Buttons
                  if (attendanceVM.isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else if (hasPunchedOut)
                    const Text(
                      "Have a great day!",
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                    )
                  else if (hasPunchedIn)
                    CustomButton(
                      title: 'PUNCH OUT NOW',
                      onTap: () async {
                        await attendanceVM.punchOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Punched Out Successfully!')),
                          );
                        }
                      },
                    )
                  else
                    CustomButton(
                      title: 'PUNCH IN NOW',
                      onTap: () async {
                        await attendanceVM.punchIn();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Punched In Successfully!')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeChip(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$label: $time",
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
