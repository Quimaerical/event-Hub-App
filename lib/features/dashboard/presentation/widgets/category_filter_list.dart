import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/category_model.dart';

class CategoryFilterList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onCategorySelected;

  const CategoryFilterList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final CategoryModel? category = isAll ? null : categories[index - 1];
          final id = isAll ? 0 : category!.id;
          final name = isAll ? 'Todas' : category!.nombre;
          final isSelected = selectedCategoryId == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(name),
              selected: isSelected,
              selectedColor: AppTheme.brandDeep,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: AppTheme.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.brandViolet
                      : AppTheme.borderDark,
                ),
              ),
              onSelected: (_) => onCategorySelected(id),
            ),
          );
        },
      ),
    );
  }
}
