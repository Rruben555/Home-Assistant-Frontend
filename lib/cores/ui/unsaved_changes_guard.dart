import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'confirm_dialog.dart';

/// Membungkus form: bila [hasChanges] true, tombol back (sistem, app bar, atau
/// Navigator.maybePop) menampilkan peringatan "data tidak akan tersimpan".
/// Navigator.pop langsung (mis. setelah berhasil menyimpan) tidak diblokir.
///
/// Guard hanya aktif saat rute form ini berada paling atas ([ModalRoute.isCurrent]).
/// Saat dialog konfirmasi / sukses sedang tampil di atas form, guard tidak ikut campur,
/// sehingga tidak bisa menutup dialog yang salah atau menumpuk dialog "Keluar tanpa menyimpan?".
/// Setelah data berhasil disimpan, set [enabled] = false agar guard sepenuhnya mati.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasChanges,
    required this.child,
    this.listenables = const [],
    this.enabled = true,
  });

  final bool Function() hasChanges;
  final Widget child;

  /// false = guard nonaktif (mis. data sudah tersimpan dan layar akan ditutup).
  final bool enabled;

  /// Controller yang perlu dipantau agar status "berubah" ikut diperbarui saat mengetik.
  final List<Listenable> listenables;

  bool _isTopRoute(BuildContext context) => ModalRoute.of(context)?.isCurrent ?? true;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge(listenables),
        child: child,
        builder: (context, child) => PopScope(
          canPop: !(enabled && hasChanges() && _isTopRoute(context)),
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !enabled) return;
            if (!context.mounted || !_isTopRoute(context)) return; // ada dialog di atas form
            final leave = await showDiscardConfirm(context);
            if (!leave || !context.mounted) return;
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              SystemNavigator.pop(); // rute terakhir (mis. layar Daftar)
            }
          },
          child: child!,
        ),
      );
}
