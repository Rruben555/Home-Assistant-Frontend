import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

const _navItems = [
  (Icons.grid_view_rounded, 'Beranda'),
  (Icons.people_alt_outlined, 'Keluarga'),
  (Icons.smart_toy_outlined, 'AI Asisten'),
  (Icons.check_circle_outline, 'Riwayat'),
  (Icons.person_outline, 'Profil'),
];

/// Shell dengan 5 tab utama. Isi tiap tab diatur oleh `appRouter`
/// (StatefulShellRoute), sehingga tiap tab punya alamat sendiri dan
/// state-nya tetap terjaga saat berpindah tab. Layar Form dan Detail
/// dibuka lewat rute terpisah di atas shell ini.
///
/// Navigasi adaptif:
///   compact  -> bottom navigation bar
///   medium   -> navigation rail (ikon + label) di sisi kiri
///   expanded -> navigation rail extended (logo + label samping)
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // GlobalKey menjaga state seluruh tab (scroll, filter, isi chat) saat
  // layout berpindah antara bottom bar <-> rail (rotasi / ubah ukuran jendela).
  final _bodyKey = GlobalKey(debugLabel: 'shell-body');

  void _select(int i) => widget.navigationShell.goBranch(
        i,
        initialLocation: i == widget.navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final index = widget.navigationShell.currentIndex;
    final body = KeyedSubtree(key: _bodyKey, child: widget.navigationShell);

    // Latar gradasi dipasang sekali di sini; Scaffold tiap tab transparan.
    if (size == ScreenSize.compact) {
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: kPageGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: body),
          bottomNavigationBar: _BottomNav(index: index, onTap: _select),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: kPageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Row(
            children: [
              _SideNav(
                index: index,
                extended: size == ScreenSize.expanded,
                onTap: _select,
              ),
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.divider),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final int index;
  final bool extended;
  final ValueChanged<int> onTap;

  const _SideNav({
    required this.index,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pola resmi agar rail bisa di-scroll pada layar yang pendek
    // (mis. HP landscape) tanpa overflow.
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              backgroundColor: AppColors.card,
              extended: extended,
              minExtendedWidth: 220,
              selectedIndex: index,
              onDestinationSelected: onTap,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              indicatorColor: AppColors.primaryLight,
              selectedIconTheme:
                  const IconThemeData(color: AppColors.primaryDark),
              unselectedIconTheme:
                  const IconThemeData(color: AppColors.textMuted),
              selectedLabelTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              unselectedLabelTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _Logo(showTitle: extended),
              ),
              destinations: [
                for (final (icon, label) in _navItems)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    label: Text(label),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Logo extends StatelessWidget {
  final bool showTitle;

  const _Logo({required this.showTitle});

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
    );
    if (!showTitle) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        const Text('Home Assistant',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ],
    );
  }
}

/// Bilah navigasi melayang berbentuk pil: tab aktif tampil sebagai pil
/// hijau gelap berisi ikon + label, tab lain hanya ikon.
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 18,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (i) {
              final selected = i == index;
              final (icon, label) = _navItems[i];
              return Tooltip(
                message: label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 46,
                    padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                            size: 22,
                            color: selected ? Colors.white : AppColors.textMuted),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Text(
                            label,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
