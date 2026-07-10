import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_assets.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/constants/app_strings.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _adminReferralController = TextEditingController();
  final _companyNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
    _adminReferralController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final authVM = context.read<AuthViewModel>();

    if (authVM.selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role (Staff or Admin)')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await authVM.signup(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        employeeId: authVM.selectedRole == 'staff' ? _employeeIdController.text.trim() : null,
        adminReferral: authVM.selectedRole == 'staff' ? _adminReferralController.text.trim() : null,
        companyName: authVM.selectedRole == 'admin' ? _companyNameController.text.trim() : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup Success')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.white24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Role Dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: authVM.selectedRole,
                            hint: const Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.white70, size: 20),
                                SizedBox(width: 10),
                                Text('Select Your Role', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            dropdownColor: AppColors.peacockDark,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                            style: const TextStyle(color: AppColors.white, fontSize: 16),
                            items: const [
                              DropdownMenuItem(
                                value: 'staff',
                                child: Row(children: [Icon(Icons.badge, color: AppColors.white, size: 20), SizedBox(width: 10), Text('Staff')]),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Row(children: [Icon(Icons.admin_panel_settings, color: AppColors.white, size: 20), SizedBox(width: 10), Text('Admin')]),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) authVM.changeRole(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (authVM.selectedRole == 'admin') ...[
                        CustomTextField(
                          controller: _companyNameController,
                          hint: 'Company / Office Name',
                          icon: Icons.business,
                          forAuth: true,
                          obscureText: false, // Ensure visible
                          validator: (value) => value!.isEmpty ? 'Enter Company Name' : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (authVM.selectedRole == 'staff') ...[
                        CustomTextField(
                          controller: _adminReferralController,
                          hint: 'Admin Referral Email',
                          icon: Icons.admin_panel_settings,
                          forAuth: true,
                          obscureText: false, // Ensure visible
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) return 'Enter Admin Email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _employeeIdController,
                          hint: 'Your Employee ID',
                          icon: Icons.badge,
                          forAuth: true,
                          obscureText: false, // Ensure visible
                          validator: (value) => value!.isEmpty ? 'Enter Employee ID' : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      CustomTextField(
                        controller: _usernameController,
                        hint: AppStrings.username,
                        icon: Icons.person,
                        forAuth: true,
                        obscureText: false, // Ensure visible
                        validator: (value) => value!.isEmpty ? 'Enter Name' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _phoneController,
                        hint: AppStrings.phone,
                        icon: Icons.phone,
                        forAuth: true,
                        obscureText: false, // Ensure visible
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length != 10 ? 'Enter 10 digits' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        hint: AppStrings.email,
                        icon: Icons.email,
                        forAuth: true,
                        obscureText: false, // Ensure visible
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'Enter Email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        hint: AppStrings.password,
                        icon: Icons.lock,
                        obscureText: true, // This one remains hidden
                        forAuth: true,
                        validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hint: AppStrings.confirmPassword,
                        icon: Icons.lock_outline,
                        obscureText: true, // This one remains hidden
                        forAuth: true,
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      authVM.isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : CustomButton(
                              title: AppStrings.signUp,
                              onTap: _handleSignup,
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: TextStyle(color: AppColors.white70)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Login', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
