import 'package:flutter/material.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/constants/app_constants.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/app_snackbar.dart';
import '../../../../../cores/ui/app_text_field.dart';
import '../../../../../cores/ui/async_builder.dart';
import '../../../../../cores/ui/confirm_dialog.dart';
import '../../../../../cores/ui/empty_state.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../../cores/ui/run_action.dart';
import '../../../../../cores/ui/unsaved_changes_guard.dart';
import '../../../../../cores/utils/date_utils.dart';
import '../../../../../cores/utils/validators.dart';
import '../../../../members/members.dart';
import '../../../domain/chore.dart';
import '../../controllers/chores_controller.dart';

/// Buat chore (choreId == null) atau ubah chore.
class ChoreFormScreen extends StatelessWidget {
  const ChoreFormScreen({super.key, this.choreId, required this.chores, required this.members});
  final String? choreId;
  final ChoresController chores;
  final MembersController members;

  @override
  Widget build(BuildContext context) => AppScaffold(
        body: AsyncBuilder<Chore?>(
          loader: () async => choreId == null ? null : chores.loadChore(choreId!),
          builder: (context, chore) => _ChoreForm(chore: chore, chores: chores, members: members),
        ),
      );
}

class _ChoreForm extends StatefulWidget {
  const _ChoreForm({this.chore, required this.chores, required this.members});
  final Chore? chore;
  final ChoresController chores;
  final MembersController members;
  @override
  State<_ChoreForm> createState() => _ChoreFormState();
}

class _ChoreFormState extends State<_ChoreForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _instructions = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String? _assigneeId;
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;
  bool _saved = false;

  // Nilai awal, untuk mendeteksi apakah form sudah diubah.
  String _iName = '';
  String _iInstructions = '';
  String? _iAssignee;
  DateTime? _iDate;
  TimeOfDay? _iTime;

  bool get _isEdit => widget.chore != null;

  bool get _dirty =>
      _name.text != _iName ||
      _instructions.text != _iInstructions ||
      _assigneeId != _iAssignee ||
      _date != _iDate ||
      _time != _iTime;

  @override
  void initState() {
    super.initState();
    final c = widget.chore;
    if (c != null) {
      _name.text = c.name;
      _instructions.text = c.instructions;
      _assigneeId = c.assigneeId;
      _setDate(AppDateUtils.dateOnly(c.scheduledAt));
      _setTime(TimeOfDay.fromDateTime(c.scheduledAt));
    } else {
      _assigneeId = widget.members.myMemberId;
    }
    _iName = _name.text;
    _iInstructions = _instructions.text;
    _iAssignee = _assigneeId;
    _iDate = _date;
    _iTime = _time;
  }

  @override
  void dispose() {
    _name.dispose();
    _instructions.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _setDate(DateTime d) {
    _date = d;
    _dateCtrl.text = AppDateUtils.formatDate(d);
  }

  void _setTime(TimeOfDay t) {
    _time = t;
    _timeCtrl.text = AppDateUtils.formatTimeOfDay(t);
  }

  void _setSubmitting(bool v) => setState(() => _submitting = v);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked != null) setState(() => _setDate(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _setTime(picked));
  }

  String? _validateDate(String? _) {
    if (_date == null) return 'Pilih tanggal chore';
    if (!_isEdit && _date!.isBefore(AppDateUtils.dateOnly(DateTime.now()))) {
      return 'Tanggal tidak boleh sebelum hari ini';
    }
    return null;
  }

  String? _validateTime(String? _) {
    if (_time == null) return 'Pilih waktu chore';
    final now = DateTime.now();
    if (!_isEdit && _date != null && AppDateUtils.isSameDay(_date!, now)) {
      final dt = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
      if (dt.isBefore(now)) return 'Waktu sudah lewat, pilih waktu setelah sekarang';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await showSubmitConfirm(
      context,
      message: _isEdit ? 'Simpan perubahan pada chore ini?' : 'Buat chore baru dengan data yang kamu isi?',
      detail: _name.text.trim(),
      confirmLabel: _isEdit ? 'Ya, simpan' : 'Ya, buat',
    );
    if (!ok || !mounted) return;
    final scheduled = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
    final chores = widget.chores;
    await runAction<Chore>(
      context,
      action: () => _isEdit
          ? chores.update(widget.chore!.copyWith(
              name: _name.text.trim(),
              assigneeId: _assigneeId,
              instructions: _instructions.text.trim(),
              scheduledAt: scheduled,
            ))
          : chores.create(Chore(
              id: '',
              familyId: '', // diisi repository sesuai keluarga terpilih
              name: _name.text.trim(),
              assigneeId: _assigneeId!,
              instructions: _instructions.text.trim(),
              scheduledAt: scheduled,
            )),
      onBusy: _setSubmitting,
      logLabel: 'Simpan chore',
      onRetry: _submit,
      onSuccess: (_) {
        setState(() => _saved = true);
        showAppSnack(context, _isEdit ? 'Perubahan chore tersimpan' : 'Chore berhasil dibuat');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.members.members;
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'Belum ada anggota',
        message: 'Keluarga ini belum punya anggota untuk diberi tugas.',
      );
    }
    final assignee = members.any((m) => m.id == _assigneeId) ? _assigneeId : null;

    return UnsavedChangesGuard(
      hasChanges: () => _dirty,
      enabled: !_saved,
      listenables: [_name, _instructions],
      child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEdit ? 'Edit tugas' : 'Buat chore', style: AppText.h1),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Nama chore',
            controller: _name,
            hint: 'Contoh: Cuci piring',
            maxLength: AppConst.maxNameLength,
            validator: (v) => Validators.text(v, 'Nama chore'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDropdownField<String>(
            label: 'Ditugaskan ke',
            value: assignee,
            hint: 'Pilih anggota',
            items: [
              for (final m in members)
                DropdownMenuItem(value: m.id, child: Text(m.name, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _assigneeId = v),
            validator: (v) => Validators.selection(v, 'Pilih anggota yang ditugaskan'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Instruksi (opsional)',
            controller: _instructions,
            hint: 'Contoh: Cuci piring, gelas, dan peralatan makan.',
            maxLines: 4,
            maxLength: AppConst.maxInstructionLength,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            validator: Validators.instructions,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: AppTextField(
                label: 'Tanggal',
                controller: _dateCtrl,
                hint: 'Pilih tanggal',
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                validator: _validateDate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Waktu',
                controller: _timeCtrl,
                hint: 'Pilih waktu',
                readOnly: true,
                onTap: _pickTime,
                suffixIcon: const Icon(Icons.access_time, size: 20),
                validator: _validateTime,
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _isEdit ? 'Simpan perubahan' : 'Buat chore',
            loading: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextButton(label: 'Batal', onPressed: _submitting ? null : () => Navigator.maybePop(context)),
        ]),
      ),
    ));
  }
}
