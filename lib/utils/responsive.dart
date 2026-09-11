import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Titik henti (breakpoint) lebar layar mengikuti pedoman Material 3:
///   compact  < 600   : HP potret          -> bottom navigation, 1 kolom
///   medium   600-899 : HP landscape/tablet -> navigation rail, konten dibatasi
///   expanded >= 900  : tablet lebar/desktop/web -> rail extended, multi-kolom
class Breakpoints {
  static const double medium = 600;
  static const double expanded = 900;
}

enum ScreenSize { compact, medium, expanded }

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= Breakpoints.expanded) return ScreenSize.expanded;
    if (w >= Breakpoints.medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }
}

/// Pengganti `ListView` biasa: isi dibatasi selebar [maxWidth] dan diletakkan
/// di tengah, tetapi area scroll tetap selebar penuh sehingga scroll mouse /
/// scrollbar tetap berfungsi di seluruh layar. Lebar diukur dari ruang yang
/// tersedia (bukan lebar layar), jadi tetap benar ketika ada navigation rail.
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  final EdgeInsets padding;
  final ScrollController? controller;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final extra =
          math.max(0.0, (constraints.maxWidth - padding.horizontal - maxWidth) / 2);
      return ListView(
        controller: controller,
        padding: padding.copyWith(
          left: padding.left + extra,
          right: padding.right + extra,
        ),
        children: children,
      );
    });
  }
}

/// Menyusun [children] dalam beberapa kolom sesuai lebar yang tersedia.
/// Jumlah kolom = sebanyak mungkin yang masih memberi tiap item minimal
/// [minItemWidth] (maksimal [maxColumns]). Tinggi tiap item mengikuti isinya
/// (tidak ada rasio tetap, jadi aman untuk teks besar).
class AdaptiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  const AdaptiveWrap({
    super.key,
    required this.children,
    this.minItemWidth = 320,
    this.maxColumns = 3,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = ((width + spacing) / (minItemWidth + spacing))
          .floor()
          .clamp(1, maxColumns);
      final itemWidth = (width - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        children: [
          for (final child in children) SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }
}

/// Membatasi lebar [child] dan menengahkannya. Tinggi mengikuti isi
/// (aman dipakai di bottomNavigationBar).
class MaxWidthBox extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MaxWidthBox({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
