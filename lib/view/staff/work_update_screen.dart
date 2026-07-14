import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/model/work_update_model.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/viewmodel/work_viewmodel.dart';

class WorkUpdateScreen extends StatefulWidget {
  const WorkUpdateScreen({super.key});

  @override
  State<WorkUpdateScreen> createState() => _WorkUpdateScreenState();
}

class _WorkUpdateScreenState extends State<WorkUpdateScreen> {
  final _workController = TextEditingController();
  String _selectedStatus = 'Program'; // Default status

  @override
  void dispose() {
    _workController.dispose();
    super.dispose();
  }

  Future<void> _submitWork() async {
    if (_workController.text.trim().isEmpty) return;

    final workVM = context.read<WorkViewModel>();
    final user = context.read<AuthViewModel>().userModel;

    if (user == null) return;

    await workVM.submitWorkUpdate(
      officeId: user.officeId,
      staffName: user.username,
      workDescription: _workController.text.trim(),
      status: _selectedStatus,
    );

    _workController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Work update submitted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workVM = context.watch<WorkViewModel>();

    return AppScaffold(
      title: "Daily Work Log",
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add New Task", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.peacockDark)),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _workController,
                  hint: "What are you working on?",
                  icon: Icons.edit_note,
                ),
                const SizedBox(height: 12),
                
                // Status Selector
                Row(
                  children: [
                    const Text("Category: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: ['Program', 'Progression', 'Completed'].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedStatus = val!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                workVM.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        title: "SUBMIT WORK LOG",
                        onTap: _submitWork,
                      ),
              ],
            ),
          ),

          // List Section
          Expanded(
            child: StreamBuilder<List<WorkUpdateModel>>(
              stream: workVM.watchMyWorkUpdates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final updates = snapshot.data ?? [];

                if (updates.isEmpty) {
                  return const Center(
                    child: Text("No work logs found for this office.", 
                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: updates.length,
                  itemBuilder: (context, index) {
                    final work = updates[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(work.status).withOpacity(0.1),
                          child: Icon(Icons.assignment_turned_in, color: _getStatusColor(work.status), size: 20),
                        ),
                        title: Text(work.workDescription, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text("${work.date} at ${work.time}", 
                          style: const TextStyle(fontSize: 11)),
                        trailing: _statusBadge(work.status),
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

  Widget _statusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.toUpperCase(), 
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Progression': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
