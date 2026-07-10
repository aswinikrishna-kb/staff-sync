import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/invoice_model.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveInvoice(InvoiceModel invoice) async {
    if (invoice.id.isEmpty) {
      await _firestore.collection('invoices').add(invoice.toMap());
    } else {
      await _firestore.collection('invoices').doc(invoice.id).update(invoice.toMap());
    }
  }

  Stream<List<InvoiceModel>> watchStaffInvoices(String staffId) {
    return _firestore
        .collection('invoices')
        .where('staffId', isEqualTo: staffId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvoiceModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<InvoiceModel>> watchOfficeInvoices(String officeId) {
    return _firestore
        .collection('invoices')
        .where('officeId', isEqualTo: officeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvoiceModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateInvoiceStatus(String id, String status, {String? comment}) async {
    await _firestore.collection('invoices').doc(id).update({
      'status': status,
      'adminComment': comment,
    });
  }

  Future<void> deleteInvoice(String id) async {
    await _firestore.collection('invoices').doc(id).delete();
  }
}
