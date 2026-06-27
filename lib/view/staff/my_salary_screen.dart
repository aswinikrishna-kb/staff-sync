import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/salary_viewmodel.dart';

class MySalaryScreen extends StatelessWidget {
  const MySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salaryVM = Provider.of<SalaryViewModel>(context);

    // Using Email as the unique identifier to match AddSalaryScreen
    String? staffEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Salary"),
      ),
      body: staffEmail == null
          ? const Center(child: Text("User email not found"))
          : StreamBuilder<QuerySnapshot>(
              stream: salaryVM.getMySalary(staffEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, size: 64, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No Salary History Found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                var data = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var salary = data[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  salary["month"] ?? "Unknown Month",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.receipt_long,
                                    color: Colors.blue),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            _salaryRow("Basic Salary",
                                "₹${salary["basicSalary"] ?? '0'}"),
                            _salaryRow("Bonus", "₹${salary["bonus"] ?? '0'}"),
                            _salaryRow("Deduction",
                                "₹${salary["deduction"] ?? '0'}",
                                isDeduction: true),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Net Salary",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "₹${salary["netSalary"] ?? '0'}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _salaryRow(String label, String value, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDeduction ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
