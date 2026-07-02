import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import '../../viewmodel/leave_viewmodel.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  String _searchQuery = "";
  String? _selectedMonth;
  String? _selectedYear;
  String? _displayDate;

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

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
  Widget build(BuildContext context) {
    final leaveVM = Provider.of<LeaveViewModel>(context);

    return AppScaffold(
      title: "Leave Requests",
      body: Column(
        children: [
          // Themed Filter Header (Same as Salary/Attendance)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.peacockLight,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search staff name...",
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.peacockLight.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.peacockDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _displayDate ?? "Filter by Month/Year",
                            style: TextStyle(
                              color: _displayDate == null ? Colors.grey[600] : AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_displayDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMonth = null;
                                _selectedYear = null;
                                _displayDate = null;
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                          ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.peacockDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: leaveVM.getLeave(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No leave requests found", style: TextStyle(color: Colors.white)));
                }

                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['staffName'] ?? "").toString().toLowerCase();
                  String fromDate = (data['fromDate'] ?? "").toString();
                  
                  bool matchesName = name.contains(_searchQuery);
                  
                  // Filter by month/year if selected
                  bool matchesDate = true;
                  if (_selectedMonth != null && _selectedYear != null) {
                    // This assumes fromDate contains month name or we check overlap. 
                    // For simplicity, we check if the string contains the year or month name.
                    matchesDate = fromDate.contains(_selectedYear!) || 
                                  fromDate.contains(_selectedMonth!.substring(0,3));
                  }
                  
                  return matchesName && matchesDate;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No matching records found", style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var leave = doc.data() as Map<String, dynamic>;
                    String status = leave["status"] ?? "Pending";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    leave["staffName"] ?? "Unknown",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.peacockDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getStatusColor(status)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("Reason: ${leave["reason"]}", style: const TextStyle(color: AppColors.black54)),
                            const SizedBox(height: 4),
                            Text("Duration: ${leave["fromDate"]} to ${leave["toDate"]}", 
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            const Divider(height: 20),
                            if (status == "Pending")
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        await leaveVM.updateStatus(doc.id, "Approved");
                                      },
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        await leaveVM.updateStatus(doc.id, "Rejected");
                                      },
                                      child: const Text("Reject"),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const Text(
                                "Action has been taken",
                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
