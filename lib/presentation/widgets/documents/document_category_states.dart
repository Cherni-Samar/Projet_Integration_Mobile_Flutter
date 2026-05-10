import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/common/app_loading.dart';

class DocumentCategoryEmptyState extends StatelessWidget {
  const DocumentCategoryEmptyState({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  });

  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(categoryIcon, size: 40, color: categoryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents in $category',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View documents in this category',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class DocumentLoadingMoreIndicator extends StatelessWidget {
  const DocumentLoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingState(padding: EdgeInsets.all(16));
  }
}
