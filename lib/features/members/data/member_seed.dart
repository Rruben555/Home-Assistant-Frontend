import '../../../shared/role/role.dart';
import '../domain/member.dart';

/// Data simulasi: 8 anggota di 2 keluarga (f1 = Keluarga Ven, f2 = Rumah Kos Melati).
/// PENTING: list yang dikembalikan harus growable (JANGAN pakai `const [...]`),
/// karena repository menambah / mengubah isinya.
class MemberSeed {
  static List<Member> members() => [
        Member(id: 'm1', familyId: 'f1', name: 'Ven', email: 'ven@example.com', role: Role.admin, userId: 'u1'),
        Member(id: 'm2', familyId: 'f1', name: 'Bro', email: 'bro@example.com', role: Role.member),
        Member(id: 'm3', familyId: 'f1', name: 'Sam', email: 'sam@example.com', role: Role.member),
        Member(id: 'm4', familyId: 'f1', name: 'Rina', email: 'rina@example.com', role: Role.member),
        Member(id: 'm5', familyId: 'f1', name: 'Dewi', email: 'dewi@example.com', role: Role.member),
        Member(id: 'm6', familyId: 'f1', name: 'Andi', email: 'andi@example.com', role: Role.member),
        Member(id: 'm7', familyId: 'f2', name: 'Ven', email: 'ven@example.com', role: Role.member, userId: 'u1'),
        Member(id: 'm8', familyId: 'f2', name: 'Tia', email: 'tia@example.com', role: Role.admin),
      ];
}
