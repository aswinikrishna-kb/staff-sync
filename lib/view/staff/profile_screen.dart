import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/staff_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final staffVM =
    Provider.of<StaffViewModel>(context);

    String email =
    FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: staffVM.getProfile(email),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text("Profile Not Found"),
            );
          }

          var data = snapshot.data!.docs.first;

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Name"),
                  subtitle: Text(data["name"]),
                ),

                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(data["email"]),
                ),

                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone"),
                  subtitle: Text(data["phone"]),
                ),

                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text("Department"),
                  subtitle: Text(data["department"]),
                ),

                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text("Designation"),
                  subtitle: Text(data["designation"]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}