import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_list_card.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/staff_model.dart';
import 'package:staff_sync/viewmodel/staff_viewmodel.dart';
import 'package:staff_sync/viewmodel/attendance_viewmodel.dart';
import 'package:staff_sync/viewmodel/salary_viewmodel.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedMonth = "May"; // Default to current
  String _selectedYear = DateTime.now().year.toString();

  final List<String> _months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<String> _years = List.generate(5, (index) => (DateTime.now().year - 2 + index).toString());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = context.read<StaffViewModel>();
    final attendanceVM = context.read<AttendanceViewModel>();
    final salaryVM = context.read<SalaryViewModel>();

    return AppScaffold(
      title: 'Staff Management',
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search staff...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.peacockDark),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdown(_selectedYear, _years, (val) => setState(() => _selectedYear = val!))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDropdown(_selectedMonth, _months, (val) => setState(() => _selectedMonth = val!))),
                  ],
                ),
              ],
            ),
          ),

          // Integrated Staff List
          Expanded(
            child: StreamBuilder<List<StaffModel>>(
              stream: staffVM.watchStaff(),
              builder: (context, staffSnapshot) {
                if (staffSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                var staffList = staffSnapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  staffList = staffList.where((s) => s.name.toLowerCase().contains(_searchQuery) || s.email.toLowerCase().contains(_searchQuery)).toList();
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: salaryVM.getSalary(), // Fetch all salaries to filter in memory for efficiency
                  builder: (context, salarySnapshot) {
                    return StreamBuilder<List>(
                      stream: attendanceVM.watchAttendance(),
                      builder: (context, attendanceSnapshot) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: staffList.length,
                          itemBuilder: (context, index) {
                            final staff = staffList[index];
                            final email = staff.email.toLowerCase();

                            // Calculate Attendance for selected month
                            final attendanceCount = (attendanceSnapshot.data ?? []).where((a) {
                              return a.staffId.toLowerCase() == email && 
                                     a.date.contains("${_selectedYear}-${_getMonthNumber(_selectedMonth)}") &&
                                     a.status == "Present";
                            }).length;

                            // Find Salary for selected month
                            String salaryInfo = "Salary: Not Added";
                            if (salarySnapshot.hasData) {
                              final salaryDoc = salarySnapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['staffId'].toString().toLowerCase() == email &&
                                       data['month'] == _selectedMonth &&
                                       data['year'] == _selectedYear;
                              }).toList();
                              if (salaryDoc.isNotEmpty) {
                                salaryInfo = "Salary: ₹${salaryDoc.first['netSalary']}";
                              }
                            }

                            return AppListCard(
                              title: staff.name,
                              icon: Icons.person,
                              subtitles: [
                                "${staff.designation} (${staff.department})",
                                "📧 ${staff.email}",
                                "📅 Presents: $attendanceCount days",
                                "💰 $salaryInfo",
                              ],
                            );
                          },
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

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _getMonthNumber(String monthName) {
    int idx = _months.indexOf(monthName) + 1;
    return idx < 10 ? "0$idx" : "$idx";
  }
}
