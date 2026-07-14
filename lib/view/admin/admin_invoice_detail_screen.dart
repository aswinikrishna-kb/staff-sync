import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/model/invoice_model.dart';
import 'package:staff_sync/viewmodel/invoice_viewmodel.dart';
import 'package:staff_sync/core/utils/pdf_helper.dart';

class AdminInvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;
  const AdminInvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<AdminInvoiceDetailScreen> createState() => _AdminInvoiceDetailScreenState();
}

class _AdminInvoiceDetailScreenState extends State<AdminInvoiceDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.invoice.adminComment ?? "";
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    await context.read<InvoiceViewModel>().updateStatus(
      widget.invoice.id, 
      status, 
      comment: _commentController.text.trim()
    );
    if (mounted) Navigator.pop(context);
  }

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
                  await PdfHelper.generateAndSendInvoice(widget.invoice, templateType: 1);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.business_outlined, color: AppColors.peacockDark),
                title: const Text("Template 2: Corporate Style"),
                onTap: () async {
                  Navigator.pop(context);
                  await PdfHelper.generateAndSendInvoice(widget.invoice, templateType: 2);
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
              _infoRow("Name", widget.invoice.clientName),
              _infoRow("Office", widget.invoice.clientOfficeName), // Added Office Name
              _infoRow("Email", widget.invoice.clientEmail),
              _infoRow("Status", widget.invoice.status),
            ]),
            const SizedBox(height: 15),
            _buildSectionCard("Items", [
              ...widget.invoice.items.map((item) => ListTile(
                title: Text(item.description),
                subtitle: Text("${item.quantity} x ₹${item.unitPrice}"),
                trailing: Text("₹${item.total}", style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
              const Divider(),
              ListTile(
                title: const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text("₹${widget.invoice.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ),
            ]),
            const SizedBox(height: 15),
            
            if (widget.invoice.status == 'Pending') ...[
              const Text("Enter Admin Feedback", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter suggestion for staff or reason for rejection...",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: CustomButton(title: "REJECT", onTap: () => _updateStatus('Rejected'))),
                  const SizedBox(width: 10),
                  Expanded(child: CustomButton(title: "APPROVE", onTap: () => _updateStatus('Approved'))),
                ],
              ),
            ] else ...[
              if (widget.invoice.adminComment != null && widget.invoice.adminComment!.isNotEmpty)
                _buildSectionCard("Admin Note", [
                  Text(widget.invoice.adminComment!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ]),
              const SizedBox(height: 20),
              if (widget.invoice.status == 'Approved') ...[
                CustomButton(title: "MARK AS PAID", onTap: () => _updateStatus('Paid')),
                const SizedBox(height: 15),
              ],
              CustomButton(
                title: widget.invoice.status == 'Paid' ? "GENERATE PAID INVOICE PDF" : "GENERATE PDF & SEND",
                onTap: () => _showTemplateSelection(context),
              ),
            ],
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
