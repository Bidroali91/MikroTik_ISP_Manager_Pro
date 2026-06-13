import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../../data/models/voucher_model.dart';

/// خيارات تخصيص كرت الطباعة: إظهار/إخفاء كل حقل.
class VoucherCardOptions {
  final bool showNetwork;
  final bool showUsername;
  final bool showPassword;
  final bool showProfile;
  final bool showPrice;
  final bool showQr;
  final String networkName;

  const VoucherCardOptions({
    this.showNetwork = true,
    this.showUsername = true,
    this.showPassword = true,
    this.showProfile = true,
    this.showPrice = true,
    this.showQr = true,
    this.networkName = 'شبكة همم',
  });

  VoucherCardOptions copyWith({
    bool? showNetwork,
    bool? showUsername,
    bool? showPassword,
    bool? showProfile,
    bool? showPrice,
    bool? showQr,
    String? networkName,
  }) {
    return VoucherCardOptions(
      showNetwork: showNetwork ?? this.showNetwork,
      showUsername: showUsername ?? this.showUsername,
      showPassword: showPassword ?? this.showPassword,
      showProfile: showProfile ?? this.showProfile,
      showPrice: showPrice ?? this.showPrice,
      showQr: showQr ?? this.showQr,
      networkName: networkName ?? this.networkName,
    );
  }
}

/// يولّد ملف PDF لكروت الإنترنت بأشكال صغيرة أنيقة قابلة للقص.
class VoucherPdf {
  static Future<Uint8List> build(
    List<VoucherModel> vouchers, {
    VoucherCardOptions options = const VoucherCardOptions(),
  }) async {
    final doc = pw.Document();
    const perPage = 10; // 2 أعمدة × 5 صفوف

    for (var start = 0; start < vouchers.length; start += perPage) {
      final slice = vouchers.skip(start).take(perPage).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          textDirection: pw.TextDirection.rtl,
          build: (context) => pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 1.9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: slice.map((v) => _card(v, options)).toList(),
          ),
        ),
      );
    }
    return doc.save();
  }

  static pw.Widget _card(VoucherModel v, VoucherCardOptions o) {
    final qr = Barcode.qrCode();
    final qrData = 'user:${v.username};pass:${v.password}';
    final lines = <pw.Widget>[];

    if (o.showNetwork) {
      lines.add(pw.Text(o.networkName,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
              fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)));
    }
    if (o.showUsername) {
      lines.add(_kv('المستخدم', v.username, bold: false));
    }
    if (o.showPassword) {
      lines.add(_kv('كلمة المرور', v.password, bold: true));
    }
    if (o.showProfile) {
      lines.add(pw.Text('${v.profileName}  •  ${v.durationHours}h',
          textDirection: pw.TextDirection.rtl,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)));
    }
    if (o.showPrice) {
      lines.add(pw.Text('${v.price} د.ل',
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)));
    }

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
              children: lines.isEmpty ? [pw.SizedBox()] : lines,
            ),
          ),
          if (o.showQr)
            pw.SizedBox(
              width: 50,
              height: 50,
              child: pw.BarcodeWidget(barcode: qr, data: qrData, drawText: false),
            ),
        ],
      ),
    );
  }

  static pw.Widget _kv(String label, String value, {required bool bold}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('$label: ',
            textDirection: pw.TextDirection.rtl,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}
