import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_list_card.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/attendance_model.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  String? _selectedDate;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.read<AttendanceViewModel>();

    return AppScaffold(
      title: 'Attendance History',
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.peacockLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.peacockDark.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search staff name...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.peacock),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                // Date Picker Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppColors.peacock, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate ?? "Filter by Date",
                                style: TextStyle(
                                  color: _selectedDate == null ? Colors.grey[600] : AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.redAccent),
                          tooltip: 'Clear Date',
                          onPressed: () => setState(() => _selectedDate = null),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: StreamBuilder<List<AttendanceModel>>(
              stream: attendanceVM.watchAttendance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var list = snapshot.data ?? [];

                // Apply Filters locally
                if (_selectedDate != null) {
                  list = list.where((a) => a.date == _selectedDate).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  list = list.where((a) => a.staffName.toLowerCase().contains(_searchQuery)).toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDate == null ? 'No Attendance Found' : 'No records found for your search',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final attendance = list[index];
                    return AppListCard(
                      title: attendance.staffName,
                      icon: Icons.fingerprint,
                      subtitles: [
                        '📅 Date: ${attendance.date}',
                        '✅ Status: ${attendance.status}',
                        if (attendance.punchInTime.isNotEmpty) '⏰ Time: ${attendance.punchInTime}',
                      ],
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
