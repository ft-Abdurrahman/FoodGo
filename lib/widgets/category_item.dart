// File: lib/widgets/category_item.dart
// Circular category chip used on the home screen

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              image: category.image.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(category.image),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
            ),
            child: category.image.isEmpty
                ? const Icon(Icons.restaurant_menu, size: 28)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
