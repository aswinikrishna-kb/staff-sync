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
          // Standard Themed Filter Header (Same as Attendance/Salary)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search staff name...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.peacockDark),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                // Date Picker Bar
                InkWell(
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
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.close, color: Colors.redAccent, size: 20),
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
                  
                  bool matchesDate = true;
                  if (_selectedMonth != null && _selectedYear != null) {
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
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.peacockDark.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.description_outlined, color: AppColors.peacockDark, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    leave["staffName"] ?? "Unknown",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppColors.peacockDark),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Reason: ${leave["reason"]}", 
                                    style: const TextStyle(color: AppColors.black54, fontSize: 14)
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 16, color: AppColors.peacockDark),
                                const SizedBox(width: 8),
                                Text(
                                  "Duration: ${leave["fromDate"]} to ${leave["toDate"]}", 
                                  style: const TextStyle(color: AppColors.black54, fontSize: 13, fontWeight: FontWeight.w500)
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            if (status == "Pending")
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text("Approve"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        await leaveVM.updateStatus(doc.id, "Approved");
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text("Reject"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        await leaveVM.updateStatus(doc.id, "Rejected");
                                      },
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Decision: $status",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic, 
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
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
