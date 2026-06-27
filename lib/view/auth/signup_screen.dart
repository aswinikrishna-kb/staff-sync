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
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final authVM = context.read<AuthViewModel>();

    final validationError = authVM.validatePasswordsMatch(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    try {
      await authVM.signup(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup Success')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to continue',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 35),
                    CustomTextField(
                      controller: _usernameController,
                      hint: AppStrings.username,
                      icon: Icons.person,
                      forAuth: true,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      hint: AppStrings.phone,
                      icon: Icons.phone,
                      forAuth: true,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      hint: AppStrings.email,
                      icon: Icons.email,
                      forAuth: true,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hint: AppStrings.password,
                      icon: Icons.lock,
                      obscureText: true,
                      forAuth: true,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hint: AppStrings.confirmPassword,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      forAuth: true,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.white24),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: authVM.selectedRole,
                          dropdownColor: AppColors.peacockDark,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white,
                          ),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Admin'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'staff',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.badge,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Staff'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              authVM.changeRole(value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    authVM.isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                          )
                        : CustomButton(
                            title: AppStrings.signUp,
                            onTap: _handleSignup,
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: AppColors.white70),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}
