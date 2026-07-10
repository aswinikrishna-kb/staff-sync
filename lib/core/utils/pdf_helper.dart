import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../model/invoice_model.dart';

class PdfHelper {
  static Future<void> generateAndSendInvoice(InvoiceModel invoice, {int templateType = 2}) async {
    final pdf = pw.Document();

    if (templateType == 1) {
      pdf.addPage(_buildTemplate1(invoice));
    } else {
      pdf.addPage(_buildTemplate2(invoice));
    }

    final pdfBytes = await pdf.save();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice_${invoice.clientName.replaceAll(' ', '_')}.pdf',
      subject: 'Invoice from ${invoice.companyName}',
      body: 'Dear ${invoice.clientName},\n\nPlease find the invoice attached.\n\nThank you.',
      emails: [invoice.clientEmail],
    );
  }

  // Template 1: Product Purchase / Modern Box Style
  static pw.Page _buildTemplate1(InvoiceModel invoice) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text("Staff Sync Invoice", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
            ),
            pw.SizedBox(height: 25),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBox1("Your Details", [
                  pw.Text(invoice.companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text("Mail: ${invoice.officeEmail}", style: pw.TextStyle(fontSize: 9)),
                  pw.Text("Staff: ${invoice.staffName}", style: pw.TextStyle(fontSize: 9)),
                ]),
                pw.SizedBox(width: 20),
                _buildBox1("Client's Details", [
                  pw.Text(invoice.clientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text("Email: ${invoice.clientEmail}", style: pw.TextStyle(fontSize: 9)),
                  pw.Text("Office: ${invoice.clientOfficeName}", style: pw.TextStyle(fontSize: 9)),
                ]),
              ],
            ),
            pw.SizedBox(height: 25),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 9),
              headers: ['Item Description', 'Qty', 'Unit Price', 'Total'],
              data: invoice.items.map((item) => [item.description, item.quantity, "INR ${item.unitPrice}", "INR ${item.total}"]).toList(),
            ),
            pw.SizedBox(height: 30),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey100,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("INR ${invoice.totalAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                  ],
                ),
              ),
            ),
            if (invoice.adminComment != null && invoice.adminComment!.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text("Admin Feedback:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.red)),
              pw.Text(invoice.adminComment!, style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
            ]
          ],
        );
      },
    );
  }

  // Template 2: Corporate Style (Based on the Softloom screenshot)
  static pw.Page _buildTemplate2(InvoiceModel invoice) {
    final double subtotal = invoice.totalAmount;
    final double sgst = subtotal * 0.09;
    final double cgst = subtotal * 0.09;
    final double grandTotal = subtotal + sgst + cgst;
    final bool isPaid = invoice.status == 'Paid';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(25),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header: Logo and Office Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("LOGO HERE", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(invoice.companyName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text(invoice.officeAddress.isNotEmpty ? invoice.officeAddress : "Office Address, main Street,", style: pw.TextStyle(fontSize: 8)),
                    pw.Text(invoice.officePhone.isNotEmpty ? "Phone: ${invoice.officePhone}" : "Phone: +91 000 000 0000", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Email: ${invoice.officeEmail}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text(invoice.officeGSTIN.isNotEmpty ? "GSTIN: ${invoice.officeGSTIN}" : "GSTIN: 32ADFFS7647K1ZO", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 15),

            // Billing Info & Status
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("INVOICE TO:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    pw.Text(invoice.clientName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(invoice.clientOfficeName, style: pw.TextStyle(fontSize: 8)),
                    if (invoice.clientAddress.isNotEmpty) pw.Text(invoice.clientAddress, style: pw.TextStyle(fontSize: 8)),
                    if (invoice.clientPhone.isNotEmpty) pw.Text("Phone: ${invoice.clientPhone}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Email: ${invoice.clientEmail}", style: pw.TextStyle(fontSize: 8)),
                    if (invoice.clientGSTIN.isNotEmpty) pw.Text("GSTIN: ${invoice.clientGSTIN}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Date of Invoice: ${invoice.createdAt.substring(0, 10)}", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: isPaid ? PdfColors.green : PdfColors.red,
                  child: pw.Text(isPaid ? "PAID" : "UNPAID", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Main Table
            pw.Table(
              columnWidths: {0: const pw.FlexColumnWidth(0.8), 1: const pw.FlexColumnWidth(5), 2: const pw.FlexColumnWidth(2)},
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _cell("SL NO", isHeader: true),
                    _cell("DESCRIPTION", isHeader: true),
                    _cell("AMOUNT", isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                ...List.generate(invoice.items.length, (index) {
                  final item = invoice.items[index];
                  return pw.TableRow(
                    children: [
                      _cell("${index + 1}"),
                      _cell(item.description),
                      _cell(item.total.toStringAsFixed(2), align: pw.TextAlign.right),
                    ],
                  );
                }),
                // Summary rows
                _sumRow("Subtotal", subtotal.toStringAsFixed(2)),
                _sumRow("SGST (9%)", sgst.toStringAsFixed(2)),
                _sumRow("CGST (9%)", cgst.toStringAsFixed(2)),
                _sumRow("TOTAL", "INR ${ (invoice.totalAmount * 1.18).toStringAsFixed(2) }", isBold: true),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text("Amount Chargeable (in words): ${_convertAmountToWords(grandTotal.toInt())} Only", style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
            
            pw.Spacer(),

            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Company PAN: ${invoice.officePAN.isNotEmpty ? invoice.officePAN : 'ADFFS7647K'}", style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 5),
                    pw.Text("Declaration:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Container(width: 250, child: pw.Text("We declare that this invoice shows the actual price of the goods described.", style: pw.TextStyle(fontSize: 7))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Bank Details", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Bank: ${invoice.bankName.isNotEmpty ? invoice.bankName : 'Federal Bank'}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("A/c: ${invoice.bankAccNo.isNotEmpty ? invoice.bankAccNo : '10040200041162'}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("IFS: ${invoice.bankIFSC.isNotEmpty ? invoice.bankIFSC : 'FDRL0001004'}", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Center(child: pw.Text("This is a Computer Generated Invoice", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600))),
            
            // Decorative Bars
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(height: 10, width: 60, color: PdfColors.blue700),
                pw.SizedBox(width: 10),
                pw.Container(height: 10, width: 60, color: PdfColors.yellow700),
                pw.SizedBox(width: 10),
                pw.Container(height: 10, width: 60, color: PdfColors.cyan700),
              ],
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildBox1(String title, List<pw.Widget> children) {
    return pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(color: PdfColors.blue, fontWeight: pw.FontWeight.bold, fontSize: 9)),
        pw.SizedBox(height: 4),
        ...children,
      ]),
    ));
  }

  static pw.Widget _cell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)));
  }

  static pw.TableRow _sumRow(String label, String value, {bool isBold = false}) {
    return pw.TableRow(children: [
      pw.SizedBox(),
      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(label, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal))),
      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal))),
    ]);
  }

  static String _convertAmountToWords(int amount) {
    if (amount == 0) return "Zero";
    var units = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"];
    var teens = ["Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"];
    var tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];
    
    String convert(int n) {
      if (n < 10) return units[n];
      if (n < 20) return teens[n - 10];
      if (n < 100) return tens[n ~/ 10] + (n % 10 != 0 ? " " + units[n % 10] : "");
      if (n < 1000) return units[n ~/ 100] + " Hundred" + (n % 100 != 0 ? " and " + convert(n % 100) : "");
      return "";
    }
    if (amount < 1000) return convert(amount);
    if (amount < 100000) return convert(amount ~/ 1000) + " Thousand" + (amount % 1000 != 0 ? " " + convert(amount % 1000) : "");
    return "Amount too large";
  }
}
