import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum TaskPriority { rendah, sedang, tinggi }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.rendah => 'Rendah',
        TaskPriority.sedang => 'Sedang',
        TaskPriority.tinggi => 'Tinggi',
      };

  Color get bg => switch (this) {
        TaskPriority.rendah => AppColors.priorityLowBg,
        TaskPriority.sedang => AppColors.priorityMediumBg,
        TaskPriority.tinggi => AppColors.priorityHighBg,
      };

  Color get fg => switch (this) {
        TaskPriority.rendah => AppColors.priorityLow,
        TaskPriority.sedang => AppColors.priorityMedium,
        TaskPriority.tinggi => AppColors.priorityHigh,
      };
}

/// Kategori sesuai SRS: Cleaning, Laundry, Maintenance, Gardening,
/// Bills, Shopping, Other.
enum TaskCategory { cleaning, laundry, maintenance, gardening, bills, shopping, other }

extension TaskCategoryX on TaskCategory {
  String get label => switch (this) {
        TaskCategory.cleaning => 'Cleaning',
        TaskCategory.laundry => 'Laundry',
        TaskCategory.maintenance => 'Maintenance',
        TaskCategory.gardening => 'Gardening',
        TaskCategory.bills => 'Bills',
        TaskCategory.shopping => 'Shopping',
        TaskCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        TaskCategory.cleaning => Icons.cleaning_services_outlined,
        TaskCategory.laundry => Icons.local_laundry_service_outlined,
        TaskCategory.maintenance => Icons.build_outlined,
        TaskCategory.gardening => Icons.yard_outlined,
        TaskCategory.bills => Icons.receipt_long_outlined,
        TaskCategory.shopping => Icons.shopping_basket_outlined,
        TaskCategory.other => Icons.grid_view_outlined,
      };
}

/// Pola pengulangan aktivitas (FR-03).
enum RepeatType { none, daily, weekly, monthly }

extension RepeatTypeX on RepeatType {
  String get label => switch (this) {
        RepeatType.none => 'Sekali',
        RepeatType.daily => 'Harian',
        RepeatType.weekly => 'Mingguan',
        RepeatType.monthly => 'Bulanan',
      };

  /// Tanggal kemunculan berikutnya setelah [d].
  DateTime next(DateTime d) => switch (this) {
        RepeatType.none => d,
        RepeatType.daily => DateTime(d.year, d.month, d.day + 1),
        RepeatType.weekly => DateTime(d.year, d.month, d.day + 7),
        RepeatType.monthly => addOneMonth(d),
      };
}

enum TaskStatus { pending, done }

/// Padanan struktur `HouseholdTask` pada SRS (bagian 5.1).
class HouseholdTask {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final DateTime date; // hanya tanggal (tanpa jam)
  final TimeOfDay time;
  final RepeatType repeatType;
  final TaskPriority priority;
  final TaskStatus status;
  /// Relasi ID ke `FamilyMember.id` (modul CRUD kedua). Null = belum
  /// ditugaskan ke siapa pun.
  final String? assignedMemberId;

  const HouseholdTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    required this.time,
    this.repeatType = RepeatType.none,
    this.priority = TaskPriority.sedang,
    this.status = TaskStatus.pending,
    this.assignedMemberId,
  });

  bool get isDone => status == TaskStatus.done;

  DateTime get scheduledAt =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  HouseholdTask copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? date,
    TimeOfDay? time,
    RepeatType? repeatType,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedMemberId,
    bool clearAssignedMember = false,
  }) {
    return HouseholdTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      repeatType: repeatType ?? this.repeatType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedMemberId: clearAssignedMember
          ? null
          : (assignedMemberId ?? this.assignedMemberId),
    );
  }
}

/// Satu catatan riwayat = satu kali aktivitas diselesaikan (FR-07).
/// Berupa snapshot supaya aktivitas berulang tetap punya riwayat
/// untuk setiap kali diselesaikan.
class HistoryEntry {
  final String id;
  final String taskId;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final RepeatType repeatType;
  final DateTime scheduledDate;
  final TimeOfDay time;
  final DateTime completedAt;
  final String? assignedMemberId;

  const HistoryEntry({
    required this.id,
    required this.taskId,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.repeatType,
    required this.scheduledDate,
    required this.time,
    required this.completedAt,
    this.assignedMemberId,
  });
}
