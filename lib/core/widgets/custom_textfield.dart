import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool forAuth;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.forAuth = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = forAuth ? AppColors.white : AppColors.black;
    final hintColor = forAuth ? AppColors.white70 : Colors.grey;
    final iconColor = forAuth ? AppColors.white : AppColors.peacockDark;
    final cardColor = forAuth
        ? AppColors.white.withValues(alpha: 0.15)
        : AppColors.white;

    return Card(
      color: cardColor,
      elevation: forAuth ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: forAuth
            ? const BorderSide(color: AppColors.white24)
            : BorderSide.none,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        style: TextStyle(color: textColor, fontSize: 16),
        cursorColor: textColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
