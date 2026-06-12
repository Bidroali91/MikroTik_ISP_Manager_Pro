import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.priority = 'medium',
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
  });
}

class ComplaintsState {
  final List<Complaint> openComplaints;
  final List<Complaint> inProgressComplaints;
  final List<Complaint> resolvedComplaints;
  final bool isLoading;
  final String? error;

  const ComplaintsState({
    this.openComplaints = const [],
    this.inProgressComplaints = const [],
    this.resolvedComplaints = const [],
    this.isLoading = false,
    this.error,
  });

  ComplaintsState copyWith({
    List<Complaint>? openComplaints,
    List<Complaint>? inProgressComplaints,
    List<Complaint>? resolvedComplaints,
    bool? isLoading,
    String? error,
  }) {
    return ComplaintsState(
      openComplaints: openComplaints ?? this.openComplaints,
      inProgressComplaints: inProgressComplaints ?? this.inProgressComplaints,
      resolvedComplaints: resolvedComplaints ?? this.resolvedComplaints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ComplaintsNotifier extends StateNotifier<ComplaintsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ComplaintsNotifier() : super(const ComplaintsState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snapshot = await _firestore
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .get();

      final complaints = snapshot.docs.map((doc) {
        final data = doc.data();
        return Complaint(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          status: data['status'] ?? 'open',
          priority: data['priority'] ?? 'medium',
          assignedTo: data['assignedTo'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
          resolution: data['resolution'],
        );
      }).toList();

      state = state.copyWith(
        openComplaints: complaints.where((c) => c.status == 'open').toList(),
        inProgressComplaints: complaints.where((c) => c.status == 'in_progress').toList(),
        resolvedComplaints: complaints.where((c) => c.status == 'resolved').toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addComplaint(String title, String description, String priority) async {
    await _firestore.collection('complaints').add({
      'title': title,
      'description': description,
      'status': 'open',
      'priority': priority,
      'createdAt': FieldValue.serverTimestamp(),
    });
    refresh();
  }

  Future<void> updateStatus(String id, String status) async {
    final update = <String, dynamic>{'status': status};
    if (status == 'resolved') {
      update['resolvedAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('complaints').doc(id).update(update);
    refresh();
  }

  Future<void> deleteComplaint(String id) async {
    await _firestore.collection('complaints').doc(id).delete();
    refresh();
  }
}

final complaintsProvider = StateNotifierProvider<ComplaintsNotifier, ComplaintsState>((ref) {
  return ComplaintsNotifier()..refresh();
});
