import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/viewmodel/work_viewmodel.dart';
import 'package:staff_sync/model/attendance_model.dart';
import 'package:staff_sync/model/work_update_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _workDescController = TextEditingController();
  String _username = "Staff Member";

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
          _username = doc.data()?['username'] ?? "Staff Member";
        });
      }
    }
  }

  @override
  void dispose() {
    _workDescController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(WorkUpdateModel work, String newStatus) async {
    await context.read<WorkViewModel>().submitWorkUpdate(
      id: work.id,
      officeId: work.officeId,
      staffName: work.staffName,
      workDescription: work.workDescription,
      status: newStatus,
      date: work.date,
      time: work.time,
    );
  }

  void _showWorkDialog(BuildContext context, String officeId, {WorkUpdateModel? existingWork}) {
    if (existingWork != null) {
      _workDescController.text = existingWork.workDescription;
    } else {
      _workDescController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.peacockDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingWork == null ? "Plan Today's Task" : "Edit Task", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: CustomTextField(
          controller: _workDescController,
          hint: "Describe your work...",
          icon: Icons.edit_note,
          forAuth: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white60))),
          if (existingWork != null)
             TextButton(
              onPressed: () async {
                await context.read<WorkViewModel>().deleteWork(existingWork.id);
                Navigator.pop(context);
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.peacockDark),
            onPressed: () async {
              if (_workDescController.text.trim().isEmpty) return;
              await context.read<WorkViewModel>().submitWorkUpdate(
                id: existingWork?.id ?? '',
                officeId: officeId,
                staffName: _username,
                workDescription: _workDescController.text.trim(),
                status: existingWork?.status ?? 'Program',
                date: existingWork?.date,
                time: existingWork?.time,
              );
              _workDescController.clear();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(existingWork == null ? "ADD" : "UPDATE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();
    final workVM = context.watch<WorkViewModel>();
    final user = context.watch<AuthViewModel>().userModel;

    return AppScaffold(
      title: 'Attendance & Work Hub',
      body: StreamBuilder<AttendanceModel?>(
        stream: attendanceVM.watchTodayStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final attendance = snapshot.data;
          final bool hasPunchedIn = attendance != null;
          final bool hasPunchedOut = attendance?.punchOutTime.isNotEmpty ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Attendance Status Card
                _buildAttendanceCard(attendanceVM, attendance, hasPunchedIn, hasPunchedOut),

                const SizedBox(height: 30),

                // 2. Work Sections (Visible only after Punch In)
                if (hasPunchedIn && user != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Work Logs", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (!hasPunchedOut)
                        IconButton(
                          onPressed: () => _showWorkDialog(context, user.officeId),
                          icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<List<WorkUpdateModel>>(
                    stream: workVM.watchMyTodaysWork(attendanceVM.currentDate),
                    builder: (context, workSnapshot) {
                      final works = workSnapshot.data ?? [];
                      if (works.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No tasks added yet. Tap '+' above.", style: TextStyle(color: Colors.white60))));
                      
                      final program = works.where((w) => w.status == 'Program').toList();
                      final progression = works.where((w) => w.status == 'Progression').toList();
                      final completed = works.where((w) => w.status == 'Completed').toList();

                      return Column(
                        children: [
                          if (program.isNotEmpty) _buildListSection("Today's Program", program, Colors.blue, hasPunchedOut),
                          if (progression.isNotEmpty) _buildListSection("In Progression", progression, Colors.orange, hasPunchedOut),
                          if (completed.isNotEmpty) _buildListSection("Completed", completed, Colors.greenAccent, hasPunchedOut),
                        ],
                      );
                    },
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListSection(String title, List<WorkUpdateModel> tasks, Color color, bool isDayEnded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(title.toUpperCase(), style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        ...tasks.map((task) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            onTap: isDayEnded ? null : () => _showWorkDialog(context, task.officeId, existingWork: task),
            title: Text(task.workDescription, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("Updated at ${task.time}", style: const TextStyle(fontSize: 10)),
            trailing: isDayEnded ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : _buildActionIcon(task),
          ),
        )),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildActionIcon(WorkUpdateModel task) {
    if (task.status == 'Program') {
      return IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.orange), onPressed: () => _updateStatus(task, 'Progression'));
    } else if (task.status == 'Progression') {
      return IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _updateStatus(task, 'Completed'));
    }
    return const Icon(Icons.verified, color: Colors.green, size: 20);
  }

  Widget _buildAttendanceCard(AttendanceViewModel vm, AttendanceModel? attendance, bool hasPunchedIn, bool hasPunchedOut) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(
            hasPunchedOut ? Icons.verified : (hasPunchedIn ? Icons.my_location : Icons.fingerprint),
            size: 60, 
            color: hasPunchedOut ? Colors.greenAccent : (hasPunchedIn ? Colors.orangeAccent : Colors.white),
          ),
          const SizedBox(height: 10),
          Text(hasPunchedOut ? "Work Day Ended" : (hasPunchedIn ? "Active Shift" : "Ready to Punch In?"), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          if (hasPunchedIn) ...[
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _infoBadge("IN: ${attendance!.punchInTime}"),
              if (hasPunchedOut) ...[const SizedBox(width: 8), _infoBadge("OUT: ${attendance.punchOutTime}")],
            ]),
            const SizedBox(height: 10),
            Text(hasPunchedOut ? attendance.punchOutLocation : attendance.punchInLocation, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
          const SizedBox(height: 20),
          if (vm.isLoading)
            const CircularProgressIndicator(color: Colors.white)
          else if (!hasPunchedOut)
            CustomButton(
              title: hasPunchedIn ? 'PUNCH OUT' : 'PUNCH IN NOW',
              onTap: () async {
                try {
                   if (hasPunchedIn) {
                      await vm.punchOut();
                   } else {
                      await vm.punchIn();
                   }
                } catch (e) {
                   if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text(e.toString().replaceAll('Exception:', ''))));
                   }
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
