import 'package:flutter/material.dart';
import '../data/models/task_model.dart';
import '../data/repositories/sagara_repository.dart';

class TaskProvider with ChangeNotifier {
  final SagaraRepository repository;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _filterState = 'ALL'; // ALL, READY, RUNNING, AWAITING_APPROVAL, COMPLETED, FAILED

  TaskProvider({required this.repository}) {
    fetchTasks();
  }

  List<TaskModel> get tasks {
    if (_filterState == 'ALL') return _tasks;
    if (_filterState == 'RUNNING') {
      return _tasks.where((t) => t.isRunning).toList();
    }
    return _tasks.where((t) => t.state == _filterState).toList();
  }

  List<TaskModel> get rawTasks => _tasks;
  bool get isLoading => _isLoading;
  String get filterState => _filterState;

  int get readyCount => _tasks.where((t) => t.isReady).length;
  int get runningCount => _tasks.where((t) => t.isRunning).length;
  int get awaitingApprovalCount => _tasks.where((t) => t.isAwaitingApproval).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get failedCount => _tasks.where((t) => t.isFailed).length;

  void setFilter(String state) {
    _filterState = state;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await repository.getTasks();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String agentId,
    required String priority,
  }) async {
    try {
      final task = await repository.createTask(
        title: title,
        description: description,
        agentId: agentId,
        priority: priority,
      );
      _tasks.insert(0, task);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelTask(String taskId) async {
    final success = await repository.cancelTask(taskId);
    if (success) {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(state: 'CANCELLED');
        notifyListeners();
      }
    }
    return success;
  }
}
