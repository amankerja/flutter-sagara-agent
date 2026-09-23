import 'package:flutter/material.dart';
import '../data/models/approval_model.dart';
import '../data/repositories/sagara_repository.dart';

class ApprovalProvider with ChangeNotifier {
  final SagaraRepository repository;

  List<ApprovalModel> _approvals = [];
  bool _isLoading = false;
  String? _processingApprovalId;

  ApprovalProvider({required this.repository}) {
    fetchApprovals();
  }

  List<ApprovalModel> get approvals => _approvals;
  List<ApprovalModel> get pendingApprovals => _approvals.where((a) => a.isPending).toList();
  int get pendingCount => pendingApprovals.length;
  bool get isLoading => _isLoading;
  String? get processingApprovalId => _processingApprovalId;

  Future<void> fetchApprovals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _approvals = List.from(await repository.getApprovals());
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String approvalId, {String? reason}) async {
    _processingApprovalId = approvalId;
    notifyListeners();

    try {
      final success = await repository.approveAction(approvalId, reason: reason);
      if (success) {
        final index = _approvals.indexWhere((a) => a.id == approvalId);
        if (index != -1) {
          _approvals[index] = _approvals[index].copyWith(state: 'APPROVED');
        }
      }
      return success;
    } finally {
      _processingApprovalId = null;
      notifyListeners();
    }
  }

  Future<bool> reject(String approvalId, {required String reason}) async {
    _processingApprovalId = approvalId;
    notifyListeners();

    try {
      final success = await repository.rejectAction(approvalId, reason: reason);
      if (success) {
        final index = _approvals.indexWhere((a) => a.id == approvalId);
        if (index != -1) {
          _approvals[index] = _approvals[index].copyWith(state: 'REJECTED');
        }
      }
      return success;
    } finally {
      _processingApprovalId = null;
      notifyListeners();
    }
  }

  Future<bool> approveAction(String approvalId, {String? reason}) =>
      approve(approvalId, reason: reason);

  Future<bool> rejectAction(String approvalId, {required String reason}) =>
      reject(approvalId, reason: reason);
}
