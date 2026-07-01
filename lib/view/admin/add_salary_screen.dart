import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/salary_model.dart';
import '../../model/staff_model.dart';
import '../../viewmodel/salary_viewmodel.dart';
import '../../viewmodel/staff_viewmodel.dart';

class AddSalaryScreen extends StatefulWidget {
  final String? editDocId;
  final SalaryModel? salary;

  const AddSalaryScreen({super.key, this.editDocId, this.salary});

  @override
  State<AddSalaryScreen> createState() => _AddSalaryScreenState();
}

class _AddSalaryScreenState extends State<AddSalaryScreen> {
  StaffModel? selectedStaff;
  String selectedMonth = "January";
  String selectedYear = DateTime.now().year.toString();

  final basicSalaryController = TextEditingController();
  final bonusController = TextEditingController();
  final deductionController = TextEditingController();

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<String> years = List.generate(10, (index) => (DateTime.now().year - 2 + index).toString());

  @override
  void initState() {
    super.initState();
    if (widget.salary != null) {
      selectedMonth = widget.salary!.month;
      selectedYear = widget.salary!.year.isNotEmpty ? widget.salary!.year : DateTime.now().year.toString();
      basicSalaryController.text = widget.salary!.basicSalary;
      bonusController.text = widget.salary!.bonus;
      deductionController.text = widget.salary!.deduction;
    }
  }

  @override
  void dispose() {
    basicSalaryController.dispose();
    bonusController.dispose();
    deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salaryVM = Provider.of<SalaryViewModel>(context);
    final staffVM = Provider.of<StaffViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editDocId == null ? "Add Salary" : "Edit Salary"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.editDocId == null)
              StreamBuilder<List<StaffModel>>(
                stream: staffVM.watchRegisteredUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No registered staff found.", style: TextStyle(color: Colors.red));
                  }

                  var staffList = snapshot.data!;
                  return DropdownButtonFormField<StaffModel>(
                    decoration: const InputDecoration(
                      labelText: "Select Registered Staff",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg),
                    ),
                    value: selectedStaff,
                    isExpanded: true,
                    items: staffList.map((staff) {
                      return DropdownMenuItem(
                        value: staff,
                        child: Text("${staff.name} (${staff.email})"),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedStaff = value),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Staff: ${widget.salary!.staffName}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 20),
            
            // Month Dropdown
            DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: const InputDecoration(
                labelText: "Select Month",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
              items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedMonth = val!),
            ),
            const SizedBox(height: 15),

            // Year Dropdown
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: const InputDecoration(
                labelText: "Select Year",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (val) => setState(() => selectedYear = val!),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: basicSalaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Basic Salary",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: bonusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Bonus",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: deductionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Deduction",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            salaryVM.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (widget.editDocId == null && selectedStaff == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a registered staff member")),
                          );
                          return;
                        }

                        double basic = double.tryParse(basicSalaryController.text) ?? 0;
                        double bonus = double.tryParse(bonusController.text) ?? 0;
                        double deduction = double.tryParse(deductionController.text) ?? 0;
                        double netSalary = basic + bonus - deduction;

                        if (widget.editDocId == null) {
                          await salaryVM.addSalary(
                            staffId: selectedStaff!.email.toLowerCase(),
                            staffName: selectedStaff!.name,
                            month: selectedMonth,
                            year: selectedYear,
                            basicSalary: basic.toString(),
                            bonus: bonus.toString(),
                            deduction: deduction.toString(),
                            netSalary: netSalary.toString(),
                          );
                        } else {
                          await salaryVM.updateSalary(
                            docId: widget.editDocId!,
                            staffId: widget.salary!.staffId,
                            staffName: widget.salary!.staffName,
                            month: selectedMonth,
                            year: selectedYear,
                            basicSalary: basic.toString(),
                            bonus: bonus.toString(),
                            deduction: deduction.toString(),
                            netSalary: netSalary.toString(),
                          );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(widget.editDocId == null ? "Salary Added Successfully" : "Salary Updated Successfully")),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.editDocId == null ? "SAVE SALARY" : "UPDATE SALARY"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
