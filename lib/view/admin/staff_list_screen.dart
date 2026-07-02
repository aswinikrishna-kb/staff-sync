import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
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
  String? _selectedMonth;
  String? _selectedYear;
  String? _displayDate;

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = months[now.month - 1];
    _selectedYear = now.year.toString();
    _displayDate = "$_selectedMonth $_selectedYear";
  }

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
        _selectedMonth = months[picked.month - 1];
        _selectedYear = picked.year.toString();
        _displayDate = "$_selectedMonth $_selectedYear";
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
    final staffVM = context.read<StaffViewModel>();
    final attendanceVM = context.read<AttendanceViewModel>();
    final salaryVM = context.read<SalaryViewModel>();

    return AppScaffold(
      title: 'Staff Management',
      body: Column(
        children: [
          // Standard Themed Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.peacockLight.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search staff name or email...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.peacockDark),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.peacockLight.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.peacockLight.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Date Picker Bar
                InkWell(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.peacockLight.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.peacockDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _displayDate ?? "Select Month/Year",
                            style: TextStyle(
                              color: _displayDate == null ? Colors.grey[600] : AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.peacockDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Staff List
          Expanded(
            child: StreamBuilder<List<StaffModel>>(
              stream: staffVM.watchStaff(),
              builder: (context, staffSnapshot) {
                if (staffSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
                
                var staffList = staffSnapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  staffList = staffList.where((s) => s.name.toLowerCase().contains(_searchQuery) || s.email.toLowerCase().contains(_searchQuery)).toList();
                }

                if (staffList.isEmpty) {
                  return const Center(child: Text("No Staff Found", style: TextStyle(color: Colors.white)));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: salaryVM.getSalary(),
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
                                     a.date.contains("${_selectedYear}-${_getMonthNumber(_selectedMonth!)}") &&
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

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.peacockLight.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: AppColors.peacockDark),
                                ),
                                title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("${staff.designation} (${staff.department})", style: const TextStyle(color: AppColors.black54)),
                                    Text("📧 ${staff.email}", style: const TextStyle(color: AppColors.black54, fontSize: 12)),
                                    const Divider(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("📅 Presents: $attendanceCount", style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.peacockDark)),
                                        Text("💰 $salaryInfo", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

  String _getMonthNumber(String monthName) {
    int idx = months.indexOf(monthName) + 1;
    return idx < 10 ? "0$idx" : "$idx";
  }
}
