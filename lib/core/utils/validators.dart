class Validators {
  static String? required(String? v) => (v == null || v.isEmpty) ? 'This field is required' : null;
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(v) ? null : 'Invalid email';
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length >= 6 ? null : 'Password must be at least 6 characters';
  }
  static String? confirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Confirm password is required';
    return v == password ? null : 'Passwords do not match';
  }
  static String? ip(String? v) {
    if (v == null || v.isEmpty) return 'IP is required';
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipRegex.hasMatch(v) ? null : 'Invalid IP address';
  }
  static String? port(String? v) {
    if (v == null || v.isEmpty) return null;
    final p = int.tryParse(v);
    return (p != null && p > 0 && p < 65536) ? null : 'Invalid port (1-65535)';
  }
  static String? number(String? v) {
    if (v == null || v.isEmpty) return null;
    return int.tryParse(v) != null ? null : 'Must be a number';
  }
  static String? positiveNumber(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    return (n != null && n > 0) ? null : 'Must be a positive number';
  }
}
