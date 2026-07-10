import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/invoice_model.dart';
import 'package:staff_sync/viewmodel/invoice_viewmodel.dart';
import 'admin_invoice_detail_screen.dart';

class AdminInvoiceListScreen extends StatelessWidget {
  const AdminInvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceVM = context.watch<InvoiceViewModel>();

    return AppScaffold(
      title: "Invoice Management",
      body: StreamBuilder<List<InvoiceModel>>(
        stream: invoiceVM.watchOfficeInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final invoices = snapshot.data ?? [];

          if (invoices.isEmpty) {
            return const Center(
              child: Text("No invoice requests found", style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.peacockLight.withOpacity(0.2),
                    child: const Icon(Icons.receipt_long, color: AppColors.peacockDark),
                  ),
                  title: Text(invoice.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("From: ${invoice.staffName}\nAmount: ₹${invoice.totalAmount}"),
                  trailing: _getStatusChip(invoice.status),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => AdminInvoiceDetailScreen(invoice: invoice))
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.green; break;
      case 'Pending': color = Colors.orange; break;
      case 'Rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: color)
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
