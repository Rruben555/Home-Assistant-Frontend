import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

/// Chip filter kategori (FR-08). `selected == null` berarti "Semua".
/// Pada layar sempit berupa daftar yang bisa digeser horizontal; pada ruang
/// lebar semua chip ditampilkan sekaligus (membungkus ke baris berikutnya).
class CategoryFilter extends StatelessWidget {
  final TaskCategory? selected;
  final int total;
  final ValueChanged<TaskCategory?> onSelect;

  const CategoryFilter({
    super.key,
    required this.selected,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _chip(null, 'Semua $total'),
      for (final c in TaskCategory.values) _chip(c, c.label),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 640) {
        return Wrap(spacing: 8, runSpacing: 8, children: chips);
      }
      return SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final chip in chips)
              Padding(padding: const EdgeInsets.only(right: 8), child: chip),
          ],
        ),
      );
    });
  }

  Widget _chip(TaskCategory? c, String label) {
    final isSelected = selected == c;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelect(c),
      selectedColor: AppColors.primaryDark,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primaryDark : AppColors.divider,
        ),
      ),
    );
  }
}
