import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/family_member.dart';
import '../models/task.dart';
import '../repository/member_repository.dart';
import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/icon_tile.dart';

/// Buka form tambah (task == null) atau ubah aktivitas.
Future<void> openTaskForm(BuildContext context, {HouseholdTask? task}) {
  return context.push(task == null ? '/task/new' : '/task/${task.id}/edit');
}

/// Satu form untuk Create (FR-01..03) dan Update (FR-06).
/// 7 field (nama, deskripsi, kategori, tanggal, waktu, pengulangan,
/// prioritas, penanggung jawab) dengan >=3 jenis input (teks, date/time
/// picker, pilihan grid/segmented, dropdown).
class TaskFormScreen extends StatefulWidget {
  final HouseholdTask? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  late TaskCategory _category;
  late DateTime _date;
  late TimeOfDay _time;
  late RepeatType _repeat;
  late TaskPriority _priority;
  String? _assignedMemberId;

  bool _isSubmitting = false;
  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    if (t != null) {
      _category = t.category;
      _date = t.date;
      _time = t.time;
      _repeat = t.repeatType;
      _priority = t.priority;
      _assignedMemberId = t.assignedMemberId;
    } else {
      final soon = DateTime.now().add(const Duration(hours: 1));
      _category = TaskCategory.cleaning;
      _date = dateOnly(soon);
      _time = TimeOfDay(hour: soon.hour, minute: 0);
      _repeat = RepeatType.none;
      _priority = TaskPriority.sedang;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final first = _date.isBefore(today) ? _date : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: first,
      lastDate: DateTime(today.year + 10),
    );
    if (picked != null) setState(() => _date = dateOnly(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    // Cegah ketukan ganda: abaikan bila proses simpan sedang berjalan.
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final orig = widget.task;
    final scheduleChanged =
        orig == null || orig.date != _date || orig.time != _time;
    final scheduled =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    if (scheduleChanged && scheduled.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content:
              Text('Tanggal & waktu sudah lewat. Pilih waktu yang akan datang.'),
        ));
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = TaskScope.of(context);
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    try {
      if (orig == null) {
        await repo.addTask(
          title: title,
          description: desc,
          category: _category,
          date: _date,
          time: _time,
          repeatType: _repeat,
          priority: _priority,
          assignedMemberId: _assignedMemberId,
        );
      } else {
        await repo.updateTask(orig.copyWith(
          title: title,
          description: desc,
          category: _category,
          date: _date,
          time: _time,
          repeatType: _repeat,
          priority: _priority,
          assignedMemberId: _assignedMemberId,
          clearAssignedMember: _assignedMemberId == null,
        ));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Perubahan aktivitas berhasil disimpan.'
              : 'Aktivitas berhasil ditambahkan.'),
        ));
      goBackOrHome(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
              'Gagal menyimpan: ${e.toString().replaceFirst('Exception: ', '')}'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = MemberScope.of(context).members;

    return GradientScaffold(
      // bottomNavigationBar tidak otomatis naik saat keyboard muncul, jadi
      // padding bawah tombol ditambah tinggi keyboard (viewInsets.bottom).
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Home Assistant',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600)),
            Text(_isEdit ? 'Ubah Aktivitas' : 'Tambah Aktivitas',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveListView(
          maxWidth: 640,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppTextField(
              label: 'Nama Aktivitas *',
              controller: _titleCtrl,
              hint: 'Contoh: Membersihkan kamar mandi',
              icon: Icons.checklist_rtl_outlined,
              maxLength: 60,
              focusNode: _titleFocus,
              nextFocusNode: _descFocus,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Nama aktivitas wajib diisi';
                if (value.length < 3) return 'Nama aktivitas minimal 3 karakter';
                if (value.length > 60) return 'Nama aktivitas maksimal 60 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Deskripsi (Opsional)',
              controller: _descCtrl,
              hint: 'Catatan atau perlengkapan yang dibutuhkan',
              maxLines: 3,
              maxLength: 200,
              focusNode: _descFocus,
              textInputAction: TextInputAction.done,
              validator: (v) => (v != null && v.length > 200)
                  ? 'Deskripsi maksimal 200 karakter'
                  : null,
            ),
            const SizedBox(height: 18),
            _label('Kategori'),
            _categoryGrid(),
            const SizedBox(height: 18),
            _label('Jadwal Pelaksanaan'),
            Row(
              children: [
                Expanded(
                  child: _pickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal',
                    value: formatDateShort(_date),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pickerTile(
                    icon: Icons.access_time,
                    label: 'Waktu',
                    value: formatTimeWib(_time),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _label('Pengulangan'),
            _segmented(),
            const SizedBox(height: 18),
            _label('Tingkat Prioritas'),
            _priorityRow(),
            const SizedBox(height: 18),
            _label('Ditugaskan Kepada (Opsional)'),
            _memberDropdown(members),
            const SizedBox(height: 18),
            _reminderInfo(),
            // Ruang ekstra agar konten terakhir tidak tertutup tombol utama.
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
          child: MaxWidthBox(
            maxWidth: 640,
            child: AppButton(
              label: _isEdit ? 'Simpan Perubahan' : 'Simpan Aktivitas',
              icon: Icons.check_circle_outline,
              onPressed: _save,
              loading: _isSubmitting,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: RepeatType.values.map((o) {
          final selected = o == _repeat;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _repeat = o),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(o.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textDark)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _priorityRow() {
    return Row(
      children: TaskPriority.values.map((p) {
        final selected = _priority == p;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p == TaskPriority.tinggi ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _priority = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? p.bg : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? p.fg : AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: p.fg),
                    const SizedBox(width: 6),
                    Text(p.label,
                        style: TextStyle(
                            color: selected ? p.fg : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _categoryGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final columns =
          constraints.maxWidth >= 600 ? TaskCategory.values.length : 4;
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 80,
        ),
        children: TaskCategory.values.map((c) {
          final selected = _category == c;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryDark : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? AppColors.primaryDark : AppColors.divider),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(c.icon,
                      color: selected ? Colors.white : AppColors.textDark,
                      size: 20),
                  const SizedBox(height: 4),
                  Text(c.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10.5,
                          color: selected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _memberDropdown(List<FamilyMember> members) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String?>(
          value: _assignedMemberId,
          isExpanded: true,
          decoration: const InputDecoration(border: InputBorder.none),
          hint: const Text('Belum ditugaskan',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Belum ditugaskan'),
            ),
            ...members.map((m) => DropdownMenuItem<String?>(
                  value: m.id,
                  child: Text('${m.name} • ${m.role.label}',
                      overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: (v) => setState(() => _assignedMemberId = v),
        ),
      ),
    );
  }

  Widget _reminderInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_outlined,
              color: AppColors.primaryDark, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pengingat akan dikirim lewat notifikasi pada tanggal dan waktu '
              'yang dipilih. (Tampilan saja — notifikasi belum diaktifkan.)',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}