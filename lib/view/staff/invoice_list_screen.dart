import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/model/invoice_model.dart';
import 'package:staff_sync/viewmodel/invoice_viewmodel.dart';
import 'create_invoice_screen.dart';
import 'staff_invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String? _selectedMonth;
  String? _selectedYear;
  String? _displayDate;
  String _searchQuery = "";

  final List<String> _months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.peacockDark,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = (picked.month).toString().padLeft(2, '0');
        _selectedYear = picked.year.toString();
        _displayDate = "${_months[picked.month - 1]} ${_selectedYear}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceVM = context.watch<InvoiceViewModel>();

    return AppScaffold(
      title: "My Invoices",
      body: Column(
        children: [
          // Standard Themed Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.peacockLight.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search client name...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.peacockDark),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Date Picker Bar
                InkWell(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.peacockDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _displayDate ?? "Filter by Month/Year",
                            style: TextStyle(
                              color: _displayDate == null ? Colors.grey[600] : AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_displayDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMonth = null;
                                _selectedYear = null;
                                _displayDate = null;
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                          ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.peacockDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<InvoiceModel>>(
              stream: invoiceVM.watchMyInvoices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                var invoices = snapshot.data ?? [];

                // Filter by Search Query
                if (_searchQuery.isNotEmpty) {
                  invoices = invoices.where((i) => i.clientName.toLowerCase().contains(_searchQuery)).toList();
                }

                // Filter by Date
                if (_selectedMonth != null && _selectedYear != null) {
                  invoices = invoices.where((i) {
                    // createdAt format: YYYY-MM-DD...
                    return i.createdAt.startsWith("${_selectedYear}-${_selectedMonth}");
                  }).toList();
                }

                // Sort by Date (Most recent first)
                invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (invoices.isEmpty) {
                  return const Center(
                    child: Text("No invoices found", style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.peacockLight.withOpacity(0.2),
                          child: const Icon(Icons.receipt_long, color: AppColors.peacockDark),
                        ),
                        title: Text(invoice.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Amount: ₹${invoice.totalAmount} • ${invoice.createdAt.substring(0, 10)}"),
                        trailing: _getStatusChip(invoice.status),
                        onTap: () {
                          if (invoice.status == 'Draft' || invoice.status == 'Rejected') {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => CreateInvoiceScreen(invoice: invoice)));
                          } else {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => StaffInvoiceDetailScreen(invoice: invoice)));
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoiceScreen())),
        )
      ],
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.green; break;
      case 'Pending': color = Colors.orange; break;
      case 'Rejected': color = Colors.red; break;
      case 'Paid': color = Colors.blue; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
