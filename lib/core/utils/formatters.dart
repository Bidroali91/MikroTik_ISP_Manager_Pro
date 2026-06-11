import 'package:intl/intl.dart';

class Formatters {
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double b = bytes.toDouble();
    int i = 0;
    while (b >= 1024 && i < units.length - 1) { b /= 1024; i++; }
    return '${b.toStringAsFixed(1)} ${units[i]}';
  }

  static String formatBitrate(int bps) {
    if (bps <= 0) return '0 bps';
    const units = ['bps', 'Kbps', 'Mbps', 'Gbps'];
    double b = bps.toDouble();
    int i = 0;
    while (b >= 1000 && i < units.length - 1) { b /= 1000; i++; }
    return '${b.toStringAsFixed(1)} ${units[i]}';
  }

  static String formatCurrency(double amount) {
    return NumberFormat('#,##0.00', 'ar').format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'ar').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm', 'ar').format(date);
  }

  static String formatUptime(String uptime) {
    return uptime.replaceAll(RegExp(r'[^\w:]'), ' ');
  }

  static String percentage(int used, int total) {
    if (total <= 0) return '—';
    return '${(used * 100 / total).toStringAsFixed(0)}%';
  }
}
