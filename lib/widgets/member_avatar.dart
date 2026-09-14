import 'package:flutter/material.dart';
import '../models/family_member.dart';

class MemberAvatar extends StatelessWidget {
  final FamilyMember member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: member.active ? 1 : 0.45,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: member.avatarColor.color,
        child: Text(
          member.initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.8,
          ),
        ),
      ),
    );
  }
}
