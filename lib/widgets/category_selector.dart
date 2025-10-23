import 'package:flutter/material.dart';
import 'package:task_sparkle/database/database.dart'; // Import Category model

class CategorySelector extends StatelessWidget {
  // 1. New parameters
  final List<Category> categories;
  final int? selectedCategoryId; // 'null' will represent "All"
  final ValueChanged<int?> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 2. We add "All" to our list
    // We can't add to the original list, so we create a new list for the UI
    final fullListLength = categories.length + 1; // +1 for the "All" button

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fullListLength,
        itemBuilder: (context, index) {
          // --- 3. Logic for "All" button vs. Category buttons ---
          final bool isAllButton = index == 0;

          // 'null' (for "All") or the category's ID
          final int? categoryId = isAllButton ? null : categories[index - 1].id;

          final String label = isAllButton ? 'All' : categories[index - 1].name;
          final bool isSelected = categoryId == selectedCategoryId;
          // --- End of logic ---

          // Get theme colors
          final selectedColor = Theme.of(context).colorScheme.onSurface;
          final unselectedColor = Theme.of(
            context,
          ).colorScheme.surface.withOpacity(0.7);
          final selectedTextColor = Theme.of(context).colorScheme.surface;
          final unselectedTextColor = Theme.of(context).colorScheme.onSurface;

          return GestureDetector(
            onTap: () {
              // 4. Use the callback to notify the parent (HomeScreen)
              onCategorySelected(categoryId);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? selectedColor
                      : unselectedColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
