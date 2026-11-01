import 'package:flutter/material.dart';
import '../../controllers/members_controller.dart';
import '../../widgets/members_view.dart';

/// Anggota (admin): ubah, hapus, dan jadikan admin.
class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key, required this.members});
  final MembersController members;
  @override
  Widget build(BuildContext context) => MembersView(members: members, isAdmin: true);
}
