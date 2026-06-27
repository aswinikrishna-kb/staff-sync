import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_assets.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/constants/app_strings.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/view/admin/admin_home_screen.dart';
import 'package:staff_sync/view/auth/signup_screen.dart';
import 'package:staff_sync/view/staff/staff_home_screen.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authVM = context.read<AuthViewModel>();

    try {
      final role = await authVM.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffHomeScreen()),
        );
      }
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
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.loginToContinue,
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 35),
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
                    const SizedBox(height: 30),
                    authVM.isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                          )
                        : CustomButton(
                            title: AppStrings.login,
                            onTap: _handleLogin,
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(color: AppColors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            AppStrings.signUp,
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
