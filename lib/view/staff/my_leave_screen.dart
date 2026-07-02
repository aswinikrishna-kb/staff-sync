import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';

import '../../viewmodel/leave_viewmodel.dart';

class MyLeaveScreen extends StatelessWidget {
  const MyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaveVM = Provider.of<LeaveViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    // Use lowercased email as the secure ID for consistency
    final String staffId = (user?.email ?? user?.uid ?? "").toLowerCase();

    return AppScaffold(
      title: "My Leave History",
      body: staffId.isEmpty
          ? const Center(
              child: Text(
                "User not logged in",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: leaveVM.getMyLeave(staffId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Something went wrong",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.white70),
                        SizedBox(height: 16),
                        Text(
                          "No leave requests found.",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                var data = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var leave = data[index].data() as Map<String, dynamic>;
                    String status = leave["status"] ?? "Pending";
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: AppColors.peacockDark.withValues(alpha: 0.2),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.peacockLight.withValues(alpha: 0.2),
                          child: const Icon(Icons.description_outlined, color: AppColors.peacockDark),
                        ),
                        title: Text(
                          leave["reason"] ?? "No Reason",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "📅 ${leave["fromDate"]} to ${leave["toDate"]}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
