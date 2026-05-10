import 'package:e_team/presentation/widgets/documents/document_category_helpers.dart';
import 'package:e_team/presentation/widgets/documents/document_category_shared.dart';
import 'package:flutter/material.dart';

class DocumentDetailsDialog extends StatelessWidget {
  const DocumentDetailsDialog({
    super.key,
    required this.document,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onViewContent,
  });

  final Map<String, dynamic> document;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onViewContent;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DocumentDialogHeader(
              title: 'Document Details',
              subtitle: category.toUpperCase(),
              icon: categoryIcon,
              color: categoryColor,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(
                      label: 'Filename',
                      value: document['originalName'] ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Size',
                      value: document['sizeFormatted'] ?? '0 Bytes',
                    ),
                    DetailRow(
                      label: 'Security Level',
                      value: document['confidentialityLevel'] ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Uploaded',
                      value: formatDocumentDate(document['uploadedAt']),
                    ),
                    if (document['tags'] != null && document['tags'].isNotEmpty)
                      TagsRow(
                        label: 'Tags',
                        tags: List<String>.from(document['tags']),
                        categoryColor: categoryColor,
                      ),
                    if (document['aiClassification'] != null)
                      DetailRow(
                        label: 'AI Confidence',
                        value:
                            '${((document['aiClassification']['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onViewContent,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Content'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentContentDialog extends StatelessWidget {
  const DocumentContentDialog({
    super.key,
    required this.document,
    required this.content,
    required this.category,
    required this.categoryColor,
  });

  final Map<String, dynamic> document;
  final String content;
  final String category;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            DocumentDialogHeader(
              title: document['originalName'] ?? 'Document Content',
              subtitle: category.toUpperCase(),
              icon: Icons.article,
              color: categoryColor,
              titleMaxLines: 1,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      content.isNotEmpty ? content : 'No content available',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Security Level: ${document['confidentialityLevel']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Text(
                    '${content.length} characters',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
