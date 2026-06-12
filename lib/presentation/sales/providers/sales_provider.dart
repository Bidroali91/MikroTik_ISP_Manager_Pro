import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItem {
  final String id;
  final String type;
  final String profile;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String customerName;
  final DateTime createdAt;

  const SaleItem({
    required this.id,
    required this.type,
    required this.profile,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.customerName,
    required this.createdAt,
  });
}

class SalesState {
  final double todayRevenue;
  final double monthlyRevenue;
  final int totalVouchers;
  final int pendingAmount;
  final List<double> weeklyData;
  final List<SaleItem> recentSales;
  final List<SaleItem> allSales;
  final bool isLoading;
  final String? error;

  const SalesState({
    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
    this.totalVouchers = 0,
    this.pendingAmount = 0,
    this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
    this.recentSales = const [],
    this.allSales = const [],
    this.isLoading = false,
    this.error,
  });

  SalesState copyWith({
    double? todayRevenue,
    double? monthlyRevenue,
    int? totalVouchers,
    int? pendingAmount,
    List<double>? weeklyData,
    List<SaleItem>? recentSales,
    List<SaleItem>? allSales,
    bool? isLoading,
    String? error,
  }) {
    return SalesState(
      todayRevenue: todayRevenue ?? this.todayRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      totalVouchers: totalVouchers ?? this.totalVouchers,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      weeklyData: weeklyData ?? this.weeklyData,
      recentSales: recentSales ?? this.recentSales,
      allSales: allSales ?? this.allSales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SalesNotifier extends StateNotifier<SalesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SalesNotifier() : super(const SalesState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      // Fetch today's sales
      final todaySnapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: todayStart)
          .orderBy('createdAt', descending: true)
          .get();

      // Fetch this month's sales
      final monthSnapshot = await _firestore
          .collection('sales')
          .where('createdAt', isGreaterThanOrEqualTo: monthStart)
          .get();

      // Calculate totals
      double todayTotal = 0;
      double monthTotal = 0;
      int totalVouchers = 0;
      List<SaleItem> recentSales = [];

      for (final doc in todaySnapshot.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] ?? 0).toDouble();
        todayTotal += amount;
        recentSales.add(_parseSale(doc.id, data));
      }

      for (final doc in monthSnapshot.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] ?? 0).toDouble();
        monthTotal += amount;
        if (data['type'] == 'voucher') totalVouchers++;
      }

      // Calculate weekly data
      final weeklyData = await _getWeeklyData();

      state = state.copyWith(
        todayRevenue: todayTotal,
        monthlyRevenue: monthTotal,
        totalVouchers: totalVouchers,
        weeklyData: weeklyData,
        recentSales: recentSales.take(10).toList(),
        allSales: recentSales,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<double>> _getWeeklyData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final snapshot = await _firestore
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: weekAgo)
        .get();

    final dailyTotals = List.filled(7, 0.0);
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dayIndex = createdAt.difference(weekAgo).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyTotals[dayIndex] += (data['totalAmount'] ?? 0).toDouble();
      }
    }
    return dailyTotals;
  }

  SaleItem _parseSale(String id, Map<String, dynamic> data) {
    return SaleItem(
      id: id,
      type: data['type'] ?? 'hotspot',
      profile: data['profile'] ?? 'default',
      quantity: data['quantity'] ?? 1,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      customerName: data['customerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> addSale({
    required String type,
    required String profile,
    required int quantity,
    required double unitPrice,
    required String customerName,
  }) async {
    await _firestore.collection('sales').add({
      'type': type,
      'profile': profile,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': unitPrice * quantity,
      'customerName': customerName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    refresh();
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  return SalesNotifier()..refresh();
});
