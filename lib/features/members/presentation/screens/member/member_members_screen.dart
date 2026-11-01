import 'package:flutter/material.dart';
import '../../controllers/members_controller.dart';
import '../../widgets/members_view.dart';

/// Anggota (anggota biasa): daftar saja, tanpa edit / hapus.
class MemberMembersScreen extends StatelessWidget {
  const MemberMembersScreen({super.key, required this.members});
  final MembersController members;
  @override
  Widget build(BuildContext context) => MembersView(members: members, isAdmin: false);
}
