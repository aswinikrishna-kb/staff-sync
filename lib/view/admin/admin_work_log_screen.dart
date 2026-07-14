import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/work_update_model.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/viewmodel/work_viewmodel.dart';
import 'admin_staff_work_detail_screen.dart';

class AdminWorkLogScreen extends StatefulWidget {
  const AdminWorkLogScreen({super.key});

  @override
  State<AdminWorkLogScreen> createState() => _AdminWorkLogScreenState();
}

class _AdminWorkLogScreenState extends State<AdminWorkLogScreen> {
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
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
        _selectedDate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workVM = context.watch<WorkViewModel>();
    final admin = context.watch<AuthViewModel>().userModel;

    return AppScaffold(
      title: "Staff Work Logs",
      body: Column(
        children: [
          // Date Selection Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.peacockDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Logs for: $_selectedDate",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.edit, size: 18, color: AppColors.peacockDark),
                  ],
                ),
              ),
            ),
          ),

          // Work Logs List
          Expanded(
            child: admin == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<WorkUpdateModel>>(
                    stream: workVM.watchOfficeWorkUpdates(admin.officeId, _selectedDate),
                    builder: (context, workSnapshot) {
                      if (workSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      final logs = workSnapshot.data ?? [];

                      // Group logs by staff name
                      Map<String, List<WorkUpdateModel>> groupedLogs = {};
                      for (var log in logs) {
                        if (!groupedLogs.containsKey(log.staffName)) {
                          groupedLogs[log.staffName] = [];
                        }
                        groupedLogs[log.staffName]!.add(log);
                      }

                      List<String> staffNames = groupedLogs.keys.toList();

                      return StreamBuilder<QuerySnapshot>(
                        // Fetch today's attendance to show locations
                        stream: FirebaseFirestore.instance
                            .collection('attendance')
                            .where('date', isEqualTo: _selectedDate)
                            .snapshots(),
                        builder: (context, attSnapshot) {
                          final attendanceDocs = attSnapshot.data?.docs ?? [];

                          if (logs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No activity recorded for this day.",
                                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: staffNames.length,
                            itemBuilder: (context, index) {
                              String staffName = staffNames[index];
                              List<WorkUpdateModel> staffWorks = groupedLogs[staffName]!;

                              // Find attendance record for this staff to get location
                              Map<String, dynamic>? attData;
                              for(var doc in attendanceDocs) {
                                if(doc['staffName'] == staffName) {
                                  attData = doc.data() as Map<String, dynamic>;
                                  break;
                                }
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.peacockDark.withOpacity(0.1),
                                    child: const Icon(Icons.person, color: AppColors.peacockDark),
                                  ),
                                  title: Text(
                                    staffName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.peacockDark),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${staffWorks.length} activities logged"),
                                      if (attData != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 12, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "Arrived at: ${attData['punchInLocation']}",
                                                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminStaffWorkDetailScreen(
                                          staffName: staffName,
                                          date: _selectedDate,
                                          logs: staffWorks,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
