import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/constants/app_constants.dart';
import '../../../../cores/ui/app_text_field.dart';
import '../../../../cores/ui/primary_button.dart';
import '../../../../cores/utils/validators.dart';
import '../../domain/family_code.dart';

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            backgroundColor: AppColors.background,
            side: const BorderSide(color: AppColors.border),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdR),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          child: const Text('Batal'),
        ),
      );
}

/// Panel "Buat keluarga": tombol Batal, kolom nama, dan tombol kirim.
/// [onCancel] null = tombol Batal nonaktif.
class CreateFamilyPanel extends StatelessWidget {
  const CreateFamilyPanel({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.submitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool submitting;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _CancelButton(onPressed: onCancel),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Nama keluarga',
            controller: nameController,
            hint: 'Contoh: Keluarga Ven',
            maxLength: AppConst.maxNameLength,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (v) => Validators.text(v, 'Nama keluarga'),
          ),
          PrimaryButton(label: 'Buat keluarga', loading: submitting, onPressed: onSubmit),
        ]),
      );
}

/// Panel "Gabung keluarga": tombol Batal, kolom kode undangan, dan tombol kirim.
/// [onCancel] null = tombol Batal nonaktif.
class JoinFamilyPanel extends StatelessWidget {
  const JoinFamilyPanel({
    super.key,
    required this.formKey,
    required this.codeController,
    required this.submitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final bool submitting;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _CancelButton(onPressed: onCancel),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Kode keluarga',
            controller: codeController,
            hint: 'Masukkan kode keluarga',
            helper: 'Minta kode undangan dari anggota keluarga.',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\- ]'))],
            onSubmitted: (_) => onSubmit(),
            validator: FamilyCode.validate,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Gabung keluarga', loading: submitting, onPressed: onSubmit),
        ]),
      );
}
