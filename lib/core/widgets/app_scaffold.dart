import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

enum AppScaffoldStyle { gradient, light }

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool showAppBar;
  final List<Widget>? actions;
  final AppScaffoldStyle style;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.showAppBar = true,
    this.actions,
    this.style = AppScaffoldStyle.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = style == AppScaffoldStyle.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.peacockDark,
      extendBodyBehindAppBar: false,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              actions: actions,
              flexibleSpace: isLight
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.appBarGradient,
                      ),
                    )
                  : null,
              backgroundColor:
                  isLight ? Colors.transparent : AppColors.peacockDark,
              elevation: isLight ? 4 : 0,
              shadowColor: AppColors.peacockDark.withValues(alpha: 0.4),
            )
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isLight ? AppColors.background : null,
          gradient: isLight ? null : AppColors.primaryGradient,
        ),
        child: body,
      ),
    );
  }
}
