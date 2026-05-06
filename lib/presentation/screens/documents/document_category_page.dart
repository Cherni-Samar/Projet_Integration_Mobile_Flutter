import 'package:flutter/material.dart';
import 'package:e_team/data/services/dexo_service.dart';

class DocumentCategoryPage extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const DocumentCategoryPage({
    Key? key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<DocumentCategoryPage> createState() => _DocumentCategoryPageState();
}

class _DocumentCategoryPageState extends State<DocumentCategoryPage> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;

  // Theme colors
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _documents.clear();
        _currentOffset = 0;
        _hasMore = true;
      }
    });

    try {
      final result = await DexoService.getDocumentsByCategory(
        category: widget.category,
        limit: _limit,
        offset: _currentOffset,
      );

      if (result['success'] == true) {
        final newDocuments = List<Map<String, dynamic>>.from(
          result['documents'] ?? [],
        );

        setState(() {
          if (refresh) {
            _documents = newDocuments;
          } else {
            _documents.addAll(newDocuments);
          }
          _hasMore = result['hasMore'] ?? false;
          _currentOffset += newDocuments.length;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading documents: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload functionality removed

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color _getSecurityColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'interne':
        return Colors.blue;
      case 'confidentiel':
        return warningColor;
      case 'secret':
        return errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getFileIcon(String? extension) {
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final securityColor = _getSecurityColor(document['confidentialityLevel']);
    final fileIcon = _getFileIcon(document['fileExtension']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDocumentDetails(document),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(fileIcon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),

              // Document info
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: securityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            document['confidentialityLevel']
                                    ?.toString()
                                    .toUpperCase() ??
                                'UNKNOWN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: securityColor,
                            ),
                          ),
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
                      'Uploaded: ${_formatDate(document['uploadedAt'])}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentDetails(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(widget.categoryIcon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Details',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
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
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Filename',
                        document['originalName'] ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        'Size',
                        document['sizeFormatted'] ?? '0 Bytes',
                      ),
                      _buildDetailRow(
                        'Security Level',
                        document['confidentialityLevel'] ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        'Uploaded',
                        _formatDate(document['uploadedAt']),
                      ),
                      if (document['tags'] != null &&
                          document['tags'].isNotEmpty)
                        _buildTagsRow(
                          'Tags',
                          List<String>.from(document['tags']),
                        ),
                      if (document['aiClassification'] != null)
                        _buildDetailRow(
                          'AI Confidence',
                          '${((document['aiClassification']['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                        ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewDocumentContent(document),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Content'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.categoryColor,
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
      ),
    );
  }

  void _viewDocumentContent(Map<String, dynamic> document) async {
    // Close the details dialog first
    Navigator.of(context).pop();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await DexoService.getDocumentContent(
        documentId: document['id'],
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        _showDocumentContentDialog(document, result['content']);
      } else {
        _showErrorSnackBar(
          result['error'] ?? 'Failed to load document content',
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _showErrorSnackBar('Error loading document content: $e');
    }
  }

  void _showDocumentContentDialog(
    Map<String, dynamic> document,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.article, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document['originalName'] ?? 'Document Content',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
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
              ),

              // Content
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

              // Footer with document info
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildTagsRow(String label, List<String> tags) {
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
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.categoryColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(widget.categoryIcon, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_documents.length} documents',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _loadDocuments(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDocuments(refresh: true),
        child: _documents.isEmpty && !_isLoading
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _documents.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _documents.length) {
                    // Load more indicator
                    if (_hasMore && !_isLoading) {
                      _loadDocuments();
                    }
                    return _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink();
                  }
                  return _buildDocumentCard(_documents[index]);
                },
              ),
      ),
      // No floating action button - upload functionality removed
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              widget.categoryIcon,
              size: 40,
              color: widget.categoryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents in ${widget.category}',
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
          // Upload functionality removed - no upload button
        ],
      ),
    );
  }
}
