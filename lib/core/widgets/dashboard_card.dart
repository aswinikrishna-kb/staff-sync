import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool classic;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.classic = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive scaling
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Dynamic sizing factors
    final double iconSize = (screenWidth * 0.11).clamp(35.0, 50.0);
    final double fontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final double paddingValue = (screenWidth * 0.04).clamp(12.0, 20.0);

    if (classic) {
      return Material(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        shadowColor: AppColors.peacockDark.withOpacity(0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: (screenWidth * 0.13).clamp(45.0, 60.0),
                  width: (screenWidth * 0.13).clamp(45.0, 60.0),
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon, 
                    color: AppColors.white, 
                    size: (screenWidth * 0.07).clamp(24.0, 30.0),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.peacockDark.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: AppColors.white.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: AppColors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontSize: (fontSize + 1).clamp(14.0, 18.0),
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
