import 'package:flutter/material.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/model/invoice_model.dart';
import 'package:staff_sync/core/utils/pdf_helper.dart';

class StaffInvoiceDetailScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const StaffInvoiceDetailScreen({super.key, required this.invoice});

  void _showTemplateSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Invoice Template",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.peacockDark),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.peacockDark),
                title: const Text("Template 1: Product Purchase Style"),
                onTap: () async {
                  Navigator.pop(context);
                  await PdfHelper.generateAndSendInvoice(invoice, templateType: 1);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.business_outlined, color: AppColors.peacockDark),
                title: const Text("Template 2: Corporate Style"),
                onTap: () async {
                  Navigator.pop(context);
                  await PdfHelper.generateAndSendInvoice(invoice, templateType: 2);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Invoice Details",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard("Client Information", [
              _infoRow("Name", invoice.clientName),
              _infoRow("Email", invoice.clientEmail),
              _infoRow("Status", invoice.status),
            ]),
            const SizedBox(height: 15),
            _buildSectionCard("Items", [
              ...invoice.items.map((item) => ListTile(
                title: Text(item.description),
                subtitle: Text("${item.quantity} x ₹${item.unitPrice}"),
                trailing: Text("₹${item.total}", style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
              const Divider(),
              ListTile(
                title: const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text("₹${invoice.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ),
            ]),
            if (invoice.adminComment != null && invoice.adminComment!.isNotEmpty) ...[
              const SizedBox(height: 15),
              _buildSectionCard("Admin Feedback", [
                Text(invoice.adminComment!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.redAccent)),
              ]),
            ],
            const SizedBox(height: 30),
            if (invoice.status == 'Approved' || invoice.status == 'Paid')
              CustomButton(
                title: invoice.status == 'Paid' ? "GENERATE PAID INVOICE PDF" : "GENERATE PDF & SEND",
                onTap: () => _showTemplateSelection(context),
              )
            else
              Center(
                child: Text(
                  "Status: ${invoice.status}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.peacockDark)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
