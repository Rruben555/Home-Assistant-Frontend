import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'task.dart';

/// Data referensi peran anggota keluarga (5 nilai referensi).
enum MemberRole { ayah, ibu, anak, kakekNenek, asistenRt }

extension MemberRoleX on MemberRole {
  String get label => switch (this) {
        MemberRole.ayah => 'Ayah',
        MemberRole.ibu => 'Ibu',
        MemberRole.anak => 'Anak',
        MemberRole.kakekNenek => 'Kakek/Nenek',
        MemberRole.asistenRt => 'Asisten Rumah Tangga',
      };
}

/// Referensi warna avatar (pilihan chip, bukan color picker bebas).
enum AvatarColorOption { hijau, mint, oranye, biru }

extension AvatarColorOptionX on AvatarColorOption {
  String get label => switch (this) {
        AvatarColorOption.hijau => 'Hijau',
        AvatarColorOption.mint => 'Mint',
        AvatarColorOption.oranye => 'Oranye',
        AvatarColorOption.biru => 'Biru',
      };

  Color get color => switch (this) {
        AvatarColorOption.hijau => AppColors.primaryDark,
        AvatarColorOption.mint => AppColors.mint,
        AvatarColorOption.oranye => AppColors.priorityMedium,
        AvatarColorOption.biru => const Color(0xFF2F6FA8),
      };
}

/// Modul CRUD kedua: Anggota Keluarga. Direlasikan ke aktivitas melalui
/// `HouseholdTask.assignedMemberId` (relasi ID antar modul).
class FamilyMember {
  final String id;
  final String name;
  final MemberRole role;
  final TaskCategory favoriteCategory;
  final AvatarColorOption avatarColor;
  final bool active;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.favoriteCategory,
    required this.avatarColor,
    this.active = true,
  });

  String get initial => name.isEmpty ? '?' : name.trim()[0].toUpperCase();

  FamilyMember copyWith({
    String? name,
    MemberRole? role,
    TaskCategory? favoriteCategory,
    AvatarColorOption? avatarColor,
    bool? active,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      favoriteCategory: favoriteCategory ?? this.favoriteCategory,
      avatarColor: avatarColor ?? this.avatarColor,
      active: active ?? this.active,
    );
  }
}
