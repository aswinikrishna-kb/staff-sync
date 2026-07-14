import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/viewmodel/theme_viewmodel.dart';
import '../../viewmodel/staff_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffVM = Provider.of<StaffViewModel>(context);
    final themeVM = context.watch<ThemeViewModel>();
    
    final user = FirebaseAuth.instance.currentUser;
    final String email = (user?.email ?? "").toLowerCase();

    return AppScaffold(
      title: "My Profile",
      body: email.isEmpty 
        ? const Center(child: Text("User session not found", style: TextStyle(color: Colors.white)))
        : StreamBuilder<QuerySnapshot>(
            stream: staffVM.getProfile(email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off, size: 80, color: Colors.white70),
                      const SizedBox(height: 16),
                      const Text(
                        "Profile details not found.",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Please contact Admin to add your profile for: $email",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }

              var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header Avatar Section
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.peacockDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data["name"] ?? "N/A",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- THEME TOGGLE SECTION ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: SwitchListTile(
                        secondary: Icon(
                          themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.peacockDark,
                        ),
                        title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: themeVM.isDarkMode,
                        onChanged: (val) => themeVM.toggleTheme(val),
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    // Details Card
                    _buildProfileCard([
                      _buildInfoTile(Icons.badge_outlined, "Employee ID", data["employeeId"]),
                      _buildInfoTile(Icons.email_outlined, "Official Email", data["email"]),
                      _buildInfoTile(Icons.phone_android_outlined, "Phone Number", data["phone"]),
                      _buildInfoTile(Icons.business_outlined, "Department", data["department"]),
                      _buildInfoTile(Icons.calendar_month_outlined, "Joining Date", data["joiningDate"]),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, dynamic value) {
    final String displayValue = (value == null || value.toString().isEmpty) ? "Not Provided" : value.toString();
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.peacockLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.peacockDark, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        displayValue,
        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
      ),
    );
  }
}
