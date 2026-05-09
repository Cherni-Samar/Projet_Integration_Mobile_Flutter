import 'package:e_team/presentation/widgets/documents/document_category_theme.dart';
import 'package:flutter/material.dart';

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
