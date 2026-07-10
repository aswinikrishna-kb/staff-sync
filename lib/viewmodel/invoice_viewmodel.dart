import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceViewModel extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();
  bool isLoading = false;

  Future<void> saveInvoice(InvoiceModel invoice) async {
    try {
      isLoading = true;
      notifyListeners();
      await _invoiceService.saveInvoice(invoice);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<InvoiceModel>> watchMyInvoices() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return _invoiceService.watchStaffInvoices(user.email!.toLowerCase());
  }

  Stream<List<InvoiceModel>> watchOfficeInvoices() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    // This is for admin, officeId is admin's UID
    return _invoiceService.watchOfficeInvoices(user.uid);
  }

  Future<void> updateStatus(String id, String status, {String? comment}) async {
    try {
      isLoading = true;
      notifyListeners();
      await _invoiceService.updateInvoiceStatus(id, status, comment: comment);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(String id) async {
    await _invoiceService.deleteInvoice(id);
  }
}
