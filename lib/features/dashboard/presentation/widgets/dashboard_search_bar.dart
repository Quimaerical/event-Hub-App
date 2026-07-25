import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar eventos...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
