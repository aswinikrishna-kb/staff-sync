import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../model/salary_model.dart';
import '../../viewmodel/salary_viewmodel.dart';
import 'add_salary_screen.dart';

class SalaryListScreen extends StatefulWidget {
  const SalaryListScreen({super.key});

  @override
  State<SalaryListScreen> createState() => _SalaryListScreenState();
}

class _SalaryListScreenState extends State<SalaryListScreen> {
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
        _displayDate = "${_selectedMonth} ${_selectedYear}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final salaryVM = Provider.of<SalaryViewModel>(context);

    return AppScaffold(
      title: "Salary Management",
      body: Column(
        children: [
          // Themed Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: Colors.white.withValues(alpha: 0.9),
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
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.peacockLight.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
              stream: salaryVM.getSalary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No records found", style: TextStyle(color: Colors.white)));
                }

                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['staffName'] ?? "").toString().toLowerCase();
                  String month = (data['month'] ?? "");
                  String year = (data['year'] ?? "");
                  
                  bool matchesName = name.contains(_searchQuery);
                  bool matchesMonth = _selectedMonth == null || month == _selectedMonth;
                  bool matchesYear = _selectedYear == null || year == _selectedYear;
                  
                  return matchesName && matchesMonth && matchesYear;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No matching records found", style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    SalaryModel salary = SalaryModel.fromMap(data);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.peacockLight.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.payments_outlined, color: AppColors.peacockDark),
                        ),
                        title: Text(
                          salary.staffName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
                        ),
                        subtitle: Text(
                          "${salary.month} ${salary.year} • Net: ₹${salary.netSalary}",
                          style: const TextStyle(color: AppColors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.blue),
                              onPressed: () => _editSalary(doc.id, salary),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(doc.id),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSalaryScreen()),
            );
          },
        ),
      ],
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this salary entry?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<SalaryViewModel>().deleteSalary(docId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editSalary(String docId, SalaryModel salary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSalaryScreen(editDocId: docId, salary: salary),
      ),
    );
  }
}
