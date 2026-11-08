import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/app_snackbar.dart';
import '../../../../../cores/ui/confirm_dialog.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../../cores/ui/run_action.dart';
import '../../../domain/family.dart';
import '../../controllers/family_controller.dart';
import '../../widgets/family_panels.dart';

enum _Mode { none, create, join }

/// Pilih keluarga: buat keluarga baru atau gabung dengan kode undangan.
/// Hanya satu panel yang terbuka. Menekan tombol lain menutup panel yang terbuka
/// lebih dulu, baru membuka panel baru.
class FamilyChoiceScreen extends StatefulWidget {
  const FamilyChoiceScreen({super.key, required this.family});
  final FamilyController family;
  @override
  State<FamilyChoiceScreen> createState() => _FamilyChoiceScreenState();
}

class _FamilyChoiceScreenState extends State<FamilyChoiceScreen> {
  static const _anim = Duration(milliseconds: 250);

  final _createKey = GlobalKey<FormState>();
  final _joinKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  _Mode _mode = _Mode.none;
  bool _transitioning = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  bool get _locked => _transitioning || _submitting;

  void _setSubmitting(bool v) => setState(() => _submitting = v);

  /// Tutup panel yang terbuka (bila ada), tunggu animasi selesai, lalu buka [target].
  Future<void> _switchTo(_Mode target) async {
    if (_locked || _mode == target) return;
    FocusScope.of(context).unfocus();
    setState(() => _transitioning = true);
    if (_mode != _Mode.none) {
      setState(() => _mode = _Mode.none);
      await Future<void>.delayed(_anim);
      if (!mounted) return;
      _name.clear();
      _code.clear();
    }
    if (!mounted) return;
    setState(() {
      _mode = target;
      _transitioning = false;
    });
  }

  void _enter(Family f) {
    widget.family.select(f.id);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  Future<void> _create() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!_createKey.currentState!.validate()) return;
    if (!widget.family.hasUser) return;
    final ok = await showSubmitConfirm(
      context,
      message: 'Buat keluarga baru dengan nama ini?',
      detail: _name.text.trim(),
      confirmLabel: 'Ya, buat',
    );
    if (!ok || !mounted) return;
    await runAction<Family>(
      context,
      action: () => widget.family.create(name: _name.text),
      onBusy: _setSubmitting,
      logLabel: 'Buat keluarga',
      onRetry: _create,
      onSuccess: (family) {
        showAppSnack(context, 'Keluarga berhasil dibuat. Kode keluarga: ${family.code}');
        _enter(family);
      },
    );
  }

  Future<void> _join() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!_joinKey.currentState!.validate()) return;
    if (!widget.family.hasUser) return;
    await runAction<Family>(
      context,
      action: () => widget.family.join(code: _code.text),
      onBusy: _setSubmitting,
      logLabel: 'Gabung keluarga',
      onSuccess: (family) {
        showAppSnack(context, 'Berhasil bergabung ke ${family.name}');
        _enter(family);
      },
    );
  }

  // ---- UI -----------------------------------------------------------------

  Widget _slot({required bool open, required Widget closed, required Widget panel}) => AnimatedSize(
        duration: _anim,
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: open ? panel : closed,
      );

  Widget _createSlot() => _slot(
        open: _mode == _Mode.create,
        closed: PrimaryButton(label: 'Buat keluarga', onPressed: () => _switchTo(_Mode.create)),
        panel: CreateFamilyPanel(
          formKey: _createKey,
          nameController: _name,
          submitting: _submitting,
          onCancel: _locked ? null : () => _switchTo(_Mode.none),
          onSubmit: _create,
        ),
      );

  Widget _joinSlot() => _slot(
        open: _mode == _Mode.join,
        closed: PrimaryButton(label: 'Gabung keluarga', onPressed: () => _switchTo(_Mode.join)),
        panel: JoinFamilyPanel(
          formKey: _joinKey,
          codeController: _code,
          submitting: _submitting,
          onCancel: _locked ? null : () => _switchTo(_Mode.none),
          onSubmit: _join,
        ),
      );

  Widget _orDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(children: [
          Expanded(child: Divider(height: 1, color: AppColors.border)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('atau', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(child: Divider(height: 1, color: AppColors.border)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final hasFamilies = widget.family.hasFamilies;
    final canPop = Navigator.canPop(context);

    return AppScaffold(
      showAppBar: canPop,
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.home_work_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(hasFamilies ? 'Tambah keluarga' : 'Belum ada keluarga',
                style: AppText.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            const Text('Buat keluarga baru atau bergabung dengan kode undangan.',
                style: AppText.muted, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            _createSlot(),
            _orDivider(),
            _joinSlot(),
          ]),
        ),
      ),
    );
  }
}
