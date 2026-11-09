import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../cores/ui/app_scaffold.dart';
import '../../features/chores/chores.dart';
import '../../features/members/members.dart';
import '../di/injection.dart';

/// Kerangka tab Beranda / Anggota.
/// Tab Beranda dan Anggota berbeda untuk admin dan anggota biasa.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.dependencies});
  final AppDependencies dependencies;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  NavigationDestination _dest(IconData icon, IconData active, String label) => NavigationDestination(
        icon: Icon(icon, color: AppColors.textMuted),
        selectedIcon: Icon(active, color: AppColors.primary),
        label: label,
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.dependencies.members,
        builder: (context, _) => _scaffold(),
      );

  Widget _scaffold() {
    final d = widget.dependencies;
    final admin = d.session.isAdmin;
    final tabs = <Widget>[
      admin
          ? AdminHomeScreen(chores: d.chores, members: d.members, family: d.family)
          : MemberHomeScreen(chores: d.chores, members: d.members, family: d.family),
      admin ? AdminMembersScreen(members: d.members) : MemberMembersScreen(members: d.members),
    ];
    return AppScaffold(
      showAppBar: false,
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          _dest(Icons.home_outlined, Icons.home, 'Beranda'),
          _dest(Icons.group_outlined, Icons.group, 'Anggota'),
        ],
      ),
    );
  }
}
