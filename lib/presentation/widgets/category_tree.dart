import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryTree extends StatelessWidget {
  final List<CategoryEntity> categories;
  final Function(CategoryEntity) onCategoryTap;
  final Function(CategoryEntity)? onCategoryEdit;
  final Function(CategoryEntity)? onCategoryDelete;

  const CategoryTree({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.onCategoryEdit,
    this.onCategoryDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(categories[index], 0);
      },
    );
  }

  Widget _buildCategoryItem(CategoryEntity category, int depth) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.folder),
          title: Text(category.name),
          contentPadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onCategoryEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onCategoryEdit!(category),
                ),
              if (onCategoryDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onCategoryDelete!(category),
                ),
            ],
          ),
          onTap: () => onCategoryTap(category),
        ),
        ...category.subcategories.map((subcategory) => 
          _buildCategoryItem(subcategory, depth + 1)
        ),
      ],
    );
  }
}
