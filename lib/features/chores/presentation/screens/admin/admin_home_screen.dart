import 'package:flutter/material.dart';
import '../../../../family/family.dart';
import '../../../../members/members.dart';
import '../../controllers/chores_controller.dart';
import '../../widgets/home_view.dart';

/// Beranda admin: dapat membuat dan mengedit chore.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key, required this.chores, required this.members, required this.family});
  final ChoresController chores;
  final MembersController members;
  final FamilyController family;
  @override
  Widget build(BuildContext context) =>
      HomeView(isAdmin: true, chores: chores, members: members, family: family);
}
