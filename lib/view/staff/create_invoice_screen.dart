import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_sync/core/constants/app_colors.dart';
import 'package:staff_sync/core/widgets/app_scaffold.dart';
import 'package:staff_sync/core/widgets/custom_button.dart';
import 'package:staff_sync/core/widgets/custom_textfield.dart';
import 'package:staff_sync/model/invoice_model.dart';
import 'package:staff_sync/viewmodel/auth_viewmodel.dart';
import 'package:staff_sync/viewmodel/invoice_viewmodel.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final InvoiceModel? invoice;
  const CreateInvoiceScreen({super.key, this.invoice});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientOfficeController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientGSTINController = TextEditingController();

  final _officeAddressController = TextEditingController();
  final _officePhoneController = TextEditingController();
  final _officeGSTINController = TextEditingController();
  final _officePANController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _bankAccNoController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankIFSCController = TextEditingController();

  final List<InvoiceItem> _items = [];
  
  final _itemDescController = TextEditingController();
  final _itemQtyController = TextEditingController();
  final _itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _clientNameController.text = widget.invoice!.clientName;
      _clientEmailController.text = widget.invoice!.clientEmail;
      _clientOfficeController.text = widget.invoice!.clientOfficeName;
      _clientAddressController.text = widget.invoice!.clientAddress;
      _clientPhoneController.text = widget.invoice!.clientPhone;
      _clientGSTINController.text = widget.invoice!.clientGSTIN;

      _officeAddressController.text = widget.invoice!.officeAddress;
      _officePhoneController.text = widget.invoice!.officePhone;
      _officeGSTINController.text = widget.invoice!.officeGSTIN;
      _officePANController.text = widget.invoice!.officePAN;

      _bankNameController.text = widget.invoice!.bankName;
      _bankAccNoController.text = widget.invoice!.bankAccNo;
      _bankBranchController.text = widget.invoice!.bankBranch;
      _bankIFSCController.text = widget.invoice!.bankIFSC;

      _items.addAll(widget.invoice!.items);
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientOfficeController.dispose();
    _clientAddressController.dispose();
    _clientPhoneController.dispose();
    _clientGSTINController.dispose();
    _officeAddressController.dispose();
    _officePhoneController.dispose();
    _officeGSTINController.dispose();
    _officePANController.dispose();
    _bankNameController.dispose();
    _bankAccNoController.dispose();
    _bankBranchController.dispose();
    _bankIFSCController.dispose();
    _itemDescController.dispose();
    _itemQtyController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  void _addItem() {
    if (_itemDescController.text.isEmpty || _itemQtyController.text.isEmpty || _itemPriceController.text.isEmpty) {
      return;
    }
    setState(() {
      _items.add(InvoiceItem(
        description: _itemDescController.text.trim(),
        quantity: int.tryParse(_itemQtyController.text) ?? 0,
        unitPrice: double.tryParse(_itemPriceController.text) ?? 0,
      ));
      _itemDescController.clear();
      _itemQtyController.clear();
      _itemPriceController.clear();
    });
  }

  Future<void> _submit(String status) async {
    final authVM = context.read<AuthViewModel>();
    final invoiceVM = context.read<InvoiceViewModel>();

    if (authVM.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: User profile not loaded")));
      return;
    }

    if (_clientNameController.text.isEmpty || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add client and items")));
      return;
    }

    final invoice = InvoiceModel(
      id: widget.invoice?.id ?? '',
      staffId: authVM.userModel!.email.toLowerCase(),
      staffName: authVM.userModel!.username,
      officeId: authVM.userModel!.officeId,
      officeEmail: authVM.userModel!.adminEmail,
      companyName: authVM.userModel!.companyName,
      officeAddress: _officeAddressController.text.trim(),
      officePhone: _officePhoneController.text.trim(),
      officeGSTIN: _officeGSTINController.text.trim(),
      officePAN: _officePANController.text.trim(),
      clientName: _clientNameController.text.trim(),
      clientEmail: _clientEmailController.text.trim(),
      clientOfficeName: _clientOfficeController.text.trim(),
      clientAddress: _clientAddressController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      clientGSTIN: _clientGSTINController.text.trim(),
      bankName: _bankNameController.text.trim(),
      bankAccNo: _bankAccNoController.text.trim(),
      bankBranch: _bankBranchController.text.trim(),
      bankIFSC: _bankIFSCController.text.trim(),
      items: List.from(_items),
      totalAmount: _totalAmount,
      status: status,
      createdAt: widget.invoice?.createdAt ?? DateTime.now().toIso8601String(),
    );

    await invoiceVM.saveInvoice(invoice);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().userModel;

    return AppScaffold(
      title: widget.invoice == null ? "Create Invoice" : "Edit Invoice",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ADMIN FEEDBACK BOX - Visible only if there is a comment
            if (widget.invoice?.adminComment != null && widget.invoice!.adminComment!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.feedback, color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text("Admin Improvement Request", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.invoice!.adminComment!,
                      style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            // FROM & TO Sections
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailsBox(
                    "Your details",
                    "FROM",
                    [
                      Text(user?.companyName ?? "Office Name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text("Mail: ${user?.adminEmail ?? ""}", style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      const SizedBox(height: 5),
                      _buildMiniInput(_officeAddressController, "Office Address"),
                      _buildMiniInput(_officePhoneController, "Office Phone"),
                      _buildMiniInput(_officeGSTINController, "GSTIN (Opt)"),
                      _buildMiniInput(_officePANController, "PAN (Opt)"),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailsBox(
                    "Client's details",
                    "TO",
                    [
                      _buildMiniInput(_clientNameController, "Client Name"),
                      _buildMiniInput(_clientOfficeController, "Client's Office"),
                      _buildMiniInput(_clientEmailController, "Client Email"),
                      _buildMiniInput(_clientAddressController, "Client Address"),
                      _buildMiniInput(_clientPhoneController, "Client Phone"),
                      _buildMiniInput(_clientGSTINController, "Client GSTIN"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            
            _buildDetailsBox(
              "Bank Details",
              "PAYMENT INFO",
              [
                _buildMiniInput(_bankNameController, "Bank Name"),
                _buildMiniInput(_bankAccNoController, "Account Number"),
                _buildMiniInput(_bankIFSCController, "IFSC Code"),
                _buildMiniInput(_bankBranchController, "Branch Name"),
              ],
            ),

            const Divider(height: 40, color: Colors.white24),

            const Text("Items", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(flex: 3, child: CustomTextField(controller: _itemDescController, hint: "Item Name", icon: Icons.description)),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: CustomTextField(controller: _itemQtyController, hint: "Qty", icon: Icons.numbers, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: CustomTextField(controller: _itemPriceController, hint: "Rate", icon: Icons.payments, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text("ADD ITEM"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.peacockDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(item.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${item.quantity} x ₹${item.unitPrice}"),
                    trailing: Text("₹${item.total}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onLongPress: () => setState(() => _items.removeAt(index)),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text("Invoice Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₹$_totalAmount", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: CustomButton(title: "SAVE DRAFT", onTap: () => _submit('Draft'))),
                const SizedBox(width: 10),
                Expanded(child: CustomButton(title: "SUBMIT", onTap: () => _submit('Pending'))),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsBox(String title, String label, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMiniInput(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 30,
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ),
    );
  }
}
