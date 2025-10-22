import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // Dummy data for our categories
  final List<String> categories = [
    'All',
    'Home',
    'Shopping',
    'Personal',
    'Work',
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Height for the category chips
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;

          // Get theme colors
          final selectedColor = Theme.of(context).colorScheme.onSurface;
          final unselectedColor = Theme.of(
            context,
          ).colorScheme.surface.withOpacity(0.7);
          final selectedTextColor = Theme.of(context).colorScheme.surface;
          final unselectedTextColor = Theme.of(context).colorScheme.onSurface;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              // In the future, this will trigger the filter
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(20), // Pill shape
                border: Border.all(
                  color: isSelected
                      ? selectedColor
                      : unselectedColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
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
