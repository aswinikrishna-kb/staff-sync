import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool forAuth;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.forAuth = false,
    this.enabled = true,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Important: Update internal state if the external requirement changes
    if (oldWidget.obscureText != widget.obscureText) {
      setState(() {
        _isObscured = widget.obscureText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.forAuth ? AppColors.white : AppColors.black;
    final hintColor = widget.forAuth ? AppColors.white70 : Colors.grey;
    final iconColor = widget.forAuth ? AppColors.white : AppColors.peacockDark;
    final cardColor = widget.forAuth
        ? AppColors.white.withOpacity(0.15)
        : AppColors.white;

    return Card(
      color: cardColor,
      elevation: widget.forAuth ? 0 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.forAuth
            ? const BorderSide(color: AppColors.white24)
            : BorderSide.none,
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscured,
        enabled: widget.enabled,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: TextStyle(color: textColor, fontSize: 16),
        cursorColor: textColor,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(widget.icon, color: iconColor, size: 22),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorStyle: TextStyle(
            color: widget.forAuth ? Colors.yellowAccent : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
