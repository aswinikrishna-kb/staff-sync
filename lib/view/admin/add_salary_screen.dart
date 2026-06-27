import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/staff_model.dart';
import '../../viewmodel/salary_viewmodel.dart';
import '../../viewmodel/staff_viewmodel.dart';

class AddSalaryScreen extends StatefulWidget {
  const AddSalaryScreen({super.key});

  @override
  State<AddSalaryScreen> createState() => _AddSalaryScreenState();
}

class _AddSalaryScreenState extends State<AddSalaryScreen> {
  StaffModel? selectedStaff;
  final monthController = TextEditingController();
  final basicSalaryController = TextEditingController();
  final bonusController = TextEditingController();
  final deductionController = TextEditingController();

  @override
  void dispose() {
    monthController.dispose();
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
        title: const Text("Add Salary"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Updated to fetch users who actually SIGNED UP via Firebase
            StreamBuilder<List<StaffModel>>(
              stream: staffVM.watchRegisteredUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No registered staff found. Please ensure they have signed up through the registration screen.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
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
                  onChanged: (value) {
                    setState(() {
                      selectedStaff = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: monthController,
              decoration: const InputDecoration(
                labelText: "Month (e.g., January 2024)",
                border: OutlineInputBorder(),
              ),
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
                        if (selectedStaff == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a registered staff member")),
                          );
                          return;
                        }

                        double basic = double.tryParse(basicSalaryController.text) ?? 0;
                        double bonus = double.tryParse(bonusController.text) ?? 0;
                        double deduction = double.tryParse(deductionController.text) ?? 0;
                        double netSalary = basic + bonus - deduction;

                        await salaryVM.addSalary(
                          staffId: selectedStaff!.email.toLowerCase(), // Gmail is the link
                          staffName: selectedStaff!.name,
                          month: monthController.text.trim(),
                          basicSalary: basic.toString(),
                          bonus: bonus.toString(),
                          deduction: deduction.toString(),
                          netSalary: netSalary.toString(),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Salary Added Successfully")),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("SAVE SALARY"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
