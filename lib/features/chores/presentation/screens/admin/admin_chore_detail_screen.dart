import 'package:flutter/material.dart';
import '../../../../members/members.dart';
import '../../controllers/chores_controller.dart';
import '../../widgets/chore_detail_view.dart';

/// Detail chore (admin): edit, hapus, tandai selesai.
class AdminChoreDetailScreen extends StatelessWidget {
  const AdminChoreDetailScreen({super.key, required this.choreId, required this.chores, required this.members});
  final String choreId;
  final ChoresController chores;
  final MembersController members;

  @override
  Widget build(BuildContext context) =>
      ChoreDetailView(choreId: choreId, isAdmin: true, chores: chores, members: members);
}
