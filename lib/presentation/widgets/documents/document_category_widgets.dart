import 'package:flutter/material.dart';

class DocumentCategoryTheme {
  const DocumentCategoryTheme._();

  static const errorColor = Color(0xFFE53E3E);
  static const warningColor = Color(0xFFFF9800);
}

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

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.categoryColor,
    required this.onTap,
  });

  final Map<String, dynamic> document;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final securityColor = getDocumentSecurityColor(
      document['confidentialityLevel'],
    );
    final fileIcon = getDocumentFileIcon(document['fileExtension']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(fileIcon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document['originalName'] ??
                          document['filename'] ??
                          'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SecurityBadge(
                          label:
                              document['confidentialityLevel']
                                  ?.toString()
                                  .toUpperCase() ??
                              'UNKNOWN',
                          color: securityColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          document['sizeFormatted'] ?? '0 Bytes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded: ${formatDocumentDate(document['uploadedAt'])}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class DocumentDialogHeader extends StatelessWidget {
  const DocumentDialogHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.titleMaxLines,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? titleMaxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: titleMaxLines,
                  overflow: titleMaxLines == null
                      ? null
                      : TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class TagsRow extends StatelessWidget {
  const TagsRow({
    super.key,
    required this.label,
    required this.tags,
    required this.categoryColor,
  });

  final String label;
  final List<String> tags;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

Color getDocumentSecurityColor(String? level) {
  switch (level?.toLowerCase()) {
    case 'public':
      return Colors.green;
    case 'interne':
      return Colors.blue;
    case 'confidentiel':
      return DocumentCategoryTheme.warningColor;
    case 'secret':
      return DocumentCategoryTheme.errorColor;
    default:
      return Colors.grey;
  }
}

String getDocumentFileIcon(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'pdf':
      return '📄';
    case 'doc':
    case 'docx':
      return '📝';
    case 'xls':
    case 'xlsx':
      return '📊';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
      return '🖼️';
    case 'txt':
      return '📃';
    default:
      return '📁';
  }
}

String formatDocumentDate(String? dateString) {
  if (dateString == null) return 'Unknown';
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    return 'Unknown';
  }
}
