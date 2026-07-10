import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';
import 'package:staff_sync/model/attendance_model.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String _username = "Loading...";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _username = doc.data()?['username'] ?? "Unknown Staff";
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();

    return AppScaffold(
      title: 'Mark Attendance',
      body: StreamBuilder<AttendanceModel?>(
        stream: attendanceVM.watchTodayStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final attendance = snapshot.data;
          bool hasPunchedIn = attendance != null;
          bool hasPunchedOut = attendance?.punchOutTime.isNotEmpty ?? false;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusIcon(hasPunchedIn, hasPunchedOut),
                  const SizedBox(height: 30),
                  Text(
                    "Hello, $_username",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Today: ${attendanceVM.currentDate}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  
                  if (hasPunchedIn) ...[
                    _timeLabel("Punch In", attendance!.punchInTime),
                    if (hasPunchedOut) _timeLabel("Punch Out", attendance.punchOutTime),
                    const SizedBox(height: 30),
                  ],

                  _buildActionButton(context, attendanceVM, hasPunchedIn, hasPunchedOut),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(bool hasPunchedIn, bool hasPunchedOut) {
    IconData icon = Icons.fingerprint;
    Color color = Colors.white;

    if (hasPunchedOut) {
      icon = Icons.check_circle;
      color = Colors.greenAccent;
    } else if (hasPunchedIn) {
      icon = Icons.timer;
      color = Colors.orangeAccent;
    }

    return Icon(icon, size: 100, color: color);
  }

  Widget _timeLabel(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        "$label: $time",
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AttendanceViewModel vm, bool hasPunchedIn, bool hasPunchedOut) {
    if (vm.isLoading) return const CircularProgressIndicator(color: Colors.white);

    if (hasPunchedOut) {
      return const Text(
        "Attendance Completed for Today",
        style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
      );
    }

    if (hasPunchedIn) {
      return CustomButton(
        title: 'PUNCH OUT NOW',
        onTap: () async {
          await vm.punchOut();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Punched Out Successfully!')),
            );
          }
        },
      );
    }

    return CustomButton(
      title: 'PUNCH IN NOW',
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || !_isInitialized) return;

        await vm.addAttendance(
          staffId: user.email!.toLowerCase(),
          staffName: _username,
          date: vm.currentDate,
          status: 'Present',
          punchInTime: vm.currentTime,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Punched In Successfully!')),
          );
        }
      },
    );
  }
}
