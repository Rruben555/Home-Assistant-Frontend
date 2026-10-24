import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/task.dart';
import '../utils/formatters.dart';

/// Repository in-memory + simulasi async. Perannya sama dengan
/// `Repository -> TaskDao` pada SRS, sehingga nanti bisa diganti Room/SQLite
/// tanpa mengubah UI. Semua data adalah data simulasi (tidak ada backend).
class TaskRepository extends ChangeNotifier {
  TaskRepository() {
    _seed();
  }

  final List<HouseholdTask> _tasks = [];
  final List<HistoryEntry> _history = [];
  int _seq = 0;

  void _seed() {
    _tasks
      ..clear()
      ..addAll(DummyData.tasks());
    _history
      ..clear()
      ..addAll(DummyData.history());
  }

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  List<HouseholdTask> get tasks => List.unmodifiable(_tasks);

  List<HistoryEntry> get history {
    final list = List.of(_history);
    list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return list;
  }

  HouseholdTask? findById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<List<HouseholdTask>> loadTasks({bool? simulateError}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return tasks;
  }

  Future<List<HistoryEntry>> loadHistory({bool? simulateError}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return history;
  }

  // ---- CREATE / UPDATE / DELETE (FR-01, FR-06) — async, try/catch di UI ----

  Future<void> addTask({
    required String title,
    required String description,
    required TaskCategory category,
    required DateTime date,
    required TimeOfDay time,
    required RepeatType repeatType,
    required TaskPriority priority,
    String? assignedMemberId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _tasks.add(HouseholdTask(
      id: _newId('t'),
      title: title,
      description: description,
      category: category,
      date: dateOnly(date),
      time: time,
      repeatType: repeatType,
      priority: priority,
      assignedMemberId: assignedMemberId,
    ));
    notifyListeners();
  }

  Future<void> updateTask(HouseholdTask task) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) return;
    _tasks[i] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void restore(HouseholdTask task) {
    if (findById(task.id) != null) return;
    _tasks.add(task);
    notifyListeners();
  }

  void unassignMember(String memberId) {
    var changed = false;
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].assignedMemberId == memberId) {
        _tasks[i] = _tasks[i].copyWith(clearAssignedMember: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ---- STATUS SELESAI + RIWAYAT (FR-05, FR-07) ----

  /// Menandai aktivitas selesai dan mengembalikan id catatan riwayat.
  String? complete(String taskId) {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return null;
    final t = _tasks[i];
    final entry = HistoryEntry(
      id: _newId('h'),
      taskId: t.id,
      title: t.title,
      description: t.description,
      category: t.category,
      priority: t.priority,
      repeatType: t.repeatType,
      scheduledDate: t.date,
      time: t.time,
      completedAt: DateTime.now(),
      assignedMemberId: t.assignedMemberId,
    );
    _history.add(entry);

    if (t.repeatType == RepeatType.none) {
      _tasks[i] = t.copyWith(status: TaskStatus.done);
    } else {
      final today = dateOnly(DateTime.now());
      var next = t.repeatType.next(t.date);
      while (!next.isAfter(today)) {
        next = t.repeatType.next(next);
      }
      _tasks[i] = t.copyWith(date: next);
    }
    notifyListeners();
    return entry.id;
  }

  /// Membatalkan status selesai: hapus catatan riwayat dan pulihkan aktivitas.
  void undoComplete(String entryId) {
    final matches = _history.where((h) => h.id == entryId);
    if (matches.isEmpty) return;
    final e = matches.first;
    _history.removeWhere((h) => h.id == entryId);

    final i = _tasks.indexWhere((t) => t.id == e.taskId);
    if (i == -1) {
      _tasks.add(HouseholdTask(
        id: e.taskId,
        title: e.title,
        description: e.description,
        category: e.category,
        date: e.scheduledDate,
        time: e.time,
        repeatType: e.repeatType,
        priority: e.priority,
        assignedMemberId: e.assignedMemberId,
      ));
    } else {
      _tasks[i] = _tasks[i].copyWith(
        date: e.scheduledDate,
        status: TaskStatus.pending,
      );
    }
    notifyListeners();
  }

  // ---- PENGELOLAAN RIWAYAT ----

  void deleteHistory(String entryId) {
    final matches = _history.where((h) => h.id == entryId);
    if (matches.isEmpty) return;
    final e = matches.first;
    _history.removeWhere((h) => h.id == entryId);
    _tasks.removeWhere((t) => t.id == e.taskId && t.isDone);
    notifyListeners();
  }
}

/// Menyediakan repository ke seluruh widget tree.
class TaskScope extends InheritedNotifier<TaskRepository> {
  const TaskScope({
    super.key,
    required TaskRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static TaskRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskScope>();
    assert(scope != null, 'TaskScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}

/// Urutan tampilan: tanggal+jam, lalu prioritas tertinggi dulu.
int compareTasks(HouseholdTask a, HouseholdTask b) {
  final c = a.scheduledAt.compareTo(b.scheduledAt);
  if (c != 0) return c;
  return b.priority.index.compareTo(a.priority.index);
}
