import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';

class AdminFinanceScreen extends StatelessWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;

    return AppScaffold(
      title: "Financial Overview",
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .where('officeId', isEqualTo: adminUid)
            .where('status', isEqualTo: 'Paid')
            .snapshots(),
        builder: (context, invSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('salary')
                .where('officeId', isEqualTo: adminUid)
                .snapshots(),
            builder: (context, salSnapshot) {
              if (invSnapshot.connectionState == ConnectionState.waiting ||
                  salSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              double totalTurnover = 0;
              double totalSalaries = 0;

              if (invSnapshot.hasData) {
                for (var doc in invSnapshot.data!.docs) {
                  totalTurnover += (doc['totalAmount'] ?? 0).toDouble();
                }
              }

              if (salSnapshot.hasData) {
                for (var doc in salSnapshot.data!.docs) {
                  totalSalaries += double.tryParse(doc['netSalary'].toString()) ?? 0;
                }
              }

              double netProfit = totalTurnover - totalSalaries;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildFinanceCard(
                      title: "Total Turnover",
                      amount: totalTurnover,
                      color: Colors.blue,
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(height: 15),
                    _buildFinanceCard(
                      title: "Total Salaries Paid",
                      amount: totalSalaries,
                      color: Colors.orange,
                      icon: Icons.payments,
                    ),
                    const SizedBox(height: 15),
                    _buildFinanceCard(
                      title: "Net Profit",
                      amount: netProfit,
                      color: Colors.greenAccent,
                      icon: Icons.trending_up,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Calculation Steps Section
                    const Text(
                      "Calculation Details",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildStepCard(
                      step: "1",
                      title: "Turnover Calculation",
                      desc: "Calculated by summing up the 'Total Amount' of all invoices marked as 'Paid' for your office.",
                      formula: "Sum (All Paid Invoices)",
                    ),
                    _buildStepCard(
                      step: "2",
                      title: "Expense Calculation",
                      desc: "Total staff expenses calculated from the 'Net Salary' field of all generated salary slips.",
                      formula: "Sum (All Staff Salaries)",
                    ),
                    _buildStepCard(
                      step: "3",
                      title: "Net Profit Logic",
                      desc: "The final profit remaining after deducting staff salary expenses from the total turnover.",
                      formula: "Turnover - Total Salaries",
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFinanceCard({required String title, required double amount, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text("₹${amount.toStringAsFixed(2)}", 
                  style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({required String step, required String title, required String desc, required String formula}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.peacockDark,
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.peacockDark)),
                const SizedBox(height: 5),
                Text(desc, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text("Formula: $formula", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
