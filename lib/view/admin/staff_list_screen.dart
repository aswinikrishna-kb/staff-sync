import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/widgets/app_list_card.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/staff_model.dart';
import 'package:staff_sync/viewmodel/staff_viewmodel.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffVM = context.read<StaffViewModel>();

    return AppScaffold(
      title: 'Staff List',
      body: StreamBuilder<List<StaffModel>>(
        stream: staffVM.watchStaff(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final staffList = snapshot.data ?? [];

          if (staffList.isEmpty) {
            return const AppEmptyMessage(
              message: 'No Staff Found',
              icon: Icons.people_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];

              return AppListCard(
                title: staff.name,
                icon: Icons.person,
                subtitles: [
                  staff.email,
                  staff.department,
                  staff.designation,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
