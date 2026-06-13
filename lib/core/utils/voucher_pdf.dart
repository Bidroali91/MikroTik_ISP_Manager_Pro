import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../../data/models/voucher_model.dart';

/// يولّد ملف PDF لكروت الإنترنت بتنسيق شبكة قابلة للقص والبيع.
class VoucherPdf {
  /// عنوان يظهر أعلى كل كرت (اسم المحل/الشبكة).
  static String shopName = 'MikroTik ISP';

  static Future<Uint8List> build(List<VoucherModel> vouchers) async {
    final doc = pw.Document();
    const perPage = 10; // 2 أعمدة × 5 صفوف

    for (var start = 0; start < vouchers.length; start += perPage) {
      final slice = vouchers.skip(start).take(perPage).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (context) => pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 1.9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: slice.map(_card).toList(),
          ),
        ),
      );
    }
    return doc.save();
  }

  static pw.Widget _card(VoucherModel v) {
    final qr = Barcode.qrCode();
    final qrData = 'user:${v.username};pass:${v.password}';
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(shopName,
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 4),
                pw.Text('User: ${v.username}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Pass: ${v.password}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('${v.profileName}  -  ${v.durationHours}h',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('${v.price} د.ل',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(
            width: 52,
            height: 52,
            child: pw.BarcodeWidget(
              barcode: qr,
              data: qrData,
              drawText: false,
            ),
          ),
        ],
      ),
    );
  }
}
