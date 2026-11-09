import 'package:flutter/material.dart';
import '../../../../family/family.dart';
import '../../../../members/members.dart';
import '../../controllers/chores_controller.dart';
import '../../widgets/home_view.dart';

/// Beranda anggota: hanya melihat chore, tanpa tombol buat / edit.
class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key, required this.chores, required this.members, required this.family});
  final ChoresController chores;
  final MembersController members;
  final FamilyController family;
  @override
  Widget build(BuildContext context) =>
      HomeView(isAdmin: false, chores: chores, members: members, family: family);
}
