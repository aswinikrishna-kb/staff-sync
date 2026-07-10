import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/viewmodel/staff_viewmodel.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _employeeIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _joiningDateController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
        _joiningDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _formKey.currentState!.validate();
    }
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final staffVM = context.read<StaffViewModel>();
    final authVM = context.read<AuthViewModel>();

    // Get Admin's company name from their profile
    String companyName = authVM.userModel?.companyName ?? "Unknown Office";

    await staffVM.addStaff(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
      joiningDate: _joiningDateController.text.trim(),
      address: _addressController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      companyName: companyName,
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _employeeIdController,
                  hint: 'Employee ID',
                  icon: Icons.badge,
                  validator: (value) => value!.isEmpty ? 'Enter Employee ID' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _nameController,
                  hint: 'Name',
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? 'Enter Name' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _phoneController,
                  hint: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) => value!.length != 10 ? 'Enter 10 digits' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter Email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _departmentController,
                  hint: 'Department',
                  icon: Icons.business,
                  validator: (value) => value!.isEmpty ? 'Enter Department' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _designationController,
                  hint: 'Designation',
                  icon: Icons.work,
                  validator: (value) => value!.isEmpty ? 'Enter Designation' : null,
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _joiningDateController,
                      hint: 'Joining Date',
                      icon: Icons.calendar_today,
                      validator: (value) => value!.isEmpty ? 'Select Joining Date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _addressController,
                  hint: 'Address',
                  icon: Icons.location_on,
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
      ),
    );
  }
}
