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

  // Template 1: Product Purchase / Modern Minimal
  static pw.Page _buildTemplate1(InvoiceModel invoice) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("INVOICE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
            pw.SizedBox(height: 25),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("From:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(invoice.companyName, style: pw.TextStyle(fontSize: 10)),
                    pw.Text(invoice.officeEmail, style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Bill To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(invoice.clientName, style: pw.TextStyle(fontSize: 10)),
                    pw.Text(invoice.clientEmail, style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              headers: ['Description', 'Qty', 'Unit Price', 'Total'],
              data: invoice.items.map((item) => [
                item.description,
                item.quantity,
                "INR ${item.unitPrice.toStringAsFixed(2)}",
                "INR ${item.total.toStringAsFixed(2)}",
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Grand Total: INR ${invoice.totalAmount.toStringAsFixed(2)}",
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
            ),
          ],
        );
      },
    );
  }

  // Template 2: Professional Corporate Style (Exact Match to Screenshot)
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
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("LOGO", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(invoice.companyName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text(invoice.officeAddress.isNotEmpty ? invoice.officeAddress : "Office HQ Address", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Email: ${invoice.officeEmail}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("GSTIN: 32ADFFS7647K1ZO", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 15),

            // Client Info & Status
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("INVOICE TO:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    pw.Text(invoice.clientName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(invoice.clientOfficeName, style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Email: ${invoice.clientEmail}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("Date of Invoice: ${invoice.createdAt.substring(0, 10)}", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: pw.BoxDecoration(color: isPaid ? PdfColors.green : PdfColors.red),
                  child: pw.Text(isPaid ? "PAID" : "UNPAID", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Items Table
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
                      _cell((index + 1).toString().padLeft(2, '0')),
                      _cell(item.description),
                      _cell(item.total.toStringAsFixed(2), align: pw.TextAlign.right),
                    ],
                  );
                }),
                _sumRow("Subtotal", subtotal.toStringAsFixed(2)),
                _sumRow("SGST (9%)", sgst.toStringAsFixed(2)),
                _sumRow("CGST (9%)", cgst.toStringAsFixed(2)),
                _sumRow("TOTAL", "INR ${grandTotal.toStringAsFixed(2)}", isBold: true),
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
                    pw.Text("Company PAN : ADFFS7647K", style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 5),
                    pw.Text("Declaration:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Container(width: 250, child: pw.Text("We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.", style: pw.TextStyle(fontSize: 7))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Bank Details", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Bank Name : Federal Bank", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("A/c No. : ${invoice.bankAccNo.isNotEmpty ? invoice.bankAccNo : '10040200041162'}", style: pw.TextStyle(fontSize: 8)),
                    pw.Text("IFS Code : ${invoice.bankIFSC.isNotEmpty ? invoice.bankIFSC : 'FDRL0001004'}", style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Center(child: pw.Text("This is a Computer Generated Invoice", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600))),
            
            // Bottom Decorative Bars
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(height: 10, width: 80, color: PdfColors.blue700),
                pw.SizedBox(width: 10),
                pw.Container(height: 10, width: 80, color: PdfColors.yellow700),
                pw.SizedBox(width: 10),
                pw.Container(height: 10, width: 80, color: PdfColors.cyan700),
              ],
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  static pw.TableRow _sumRow(String label, String value, {bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.SizedBox(),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(label, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(value, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal))),
      ],
    );
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
