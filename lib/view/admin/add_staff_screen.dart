import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/viewmodel/staff_viewmodel.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    final staffVM = context.read<StaffViewModel>();

    await staffVM.addStaff(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Staff Added Successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = context.watch<StaffViewModel>();

    return AppScaffold(
      title: 'Add Staff',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hint: 'Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _phoneController,
                hint: 'Phone',
                icon: Icons.phone,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _departmentController,
                hint: 'Department',
                icon: Icons.business,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _designationController,
                hint: 'Designation',
                icon: Icons.work,
              ),
              const SizedBox(height: 30),
              staffVM.isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      title: 'SAVE STAFF',
                      onTap: _saveStaff,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
