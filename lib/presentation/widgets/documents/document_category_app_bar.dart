import 'package:flutter/material.dart';

class DocumentCategoryAppBarTitle extends StatelessWidget {
  const DocumentCategoryAppBarTitle({
    super.key,
    required this.category,
    required this.categoryIcon,
    required this.documentCount,
  });

  final String category;
  final IconData categoryIcon;
  final int documentCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(categoryIcon, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$documentCount documents',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}
