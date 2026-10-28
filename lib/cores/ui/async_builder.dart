import 'package:flutter/material.dart';
import '../errors/app_exception.dart';
import '../../app/theme/app_theme.dart';
import 'empty_state.dart';

/// Menangani tiga state: loading, data, error (+ tombol Coba lagi).
/// - [refreshOn]: muat ulang diam-diam saat repository berubah (sinkron antarlayar).
class AsyncBuilder<T> extends StatefulWidget {
  const AsyncBuilder({super.key, required this.loader, required this.builder, this.refreshOn});

  final Future<T> Function() loader;
  final Widget Function(BuildContext context, T data) builder;
  final Listenable? refreshOn;

  @override
  State<AsyncBuilder<T>> createState() => _AsyncBuilderState<T>();
}

class _AsyncBuilderState<T> extends State<AsyncBuilder<T>> {
  T? _data;
  bool _hasData = false;
  bool _loading = true;
  Object? _error;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    widget.refreshOn?.addListener(_silentReload);
    _load();
  }

  @override
  void dispose() {
    widget.refreshOn?.removeListener(_silentReload);
    super.dispose();
  }

  void _silentReload() {
    if (_hasData) _load(silent: true);
  }

  Future<void> _load({bool silent = false}) async {
    final token = ++_token;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final result = await widget.loader();
      if (!mounted || token != _token) return;
      setState(() {
        _data = result;
        _hasData = true;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || token != _token) return;
      if (silent && _hasData) return; // pertahankan data lama
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      final msg = _error is AppException ? (_error as AppException).message : 'Terjadi kesalahan tak terduga.';
      return Center(child: SingleChildScrollView(child: ErrorState(message: msg, onRetry: () => _load())));
    }
    return widget.builder(context, _data as T);
  }
}
