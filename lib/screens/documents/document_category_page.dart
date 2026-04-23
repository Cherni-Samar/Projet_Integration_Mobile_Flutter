import 'package:flutter/material.dart';
import '../../services/dexo_service.dart';

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

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF4CAF50);
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
        userId: 'current_user',
        limit: _limit,
        offset: _currentOffset,
      );

      if (result['success'] == true) {
        final newDocuments = List<Map<String, dynamic>>.from(result['documents'] ?? []);
        
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

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
      case 'csv':
        return '📋';
      default:
        return '📎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - Documents'),
        backgroundColor: widget.categoryColor,
        elevation: 0,
      ),
      body: _isLoading && _documents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.categoryIcon,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No documents',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _documents.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _documents.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () => _loadDocuments(),
                          child: const Text('Load More'),
                        ),
                      );
                    }

                    final doc = _documents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Text(_getFileIcon(doc['extension']), style: const TextStyle(fontSize: 24)),
                        title: Text(doc['filename'] ?? 'Unnamed'),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSecurityColor(doc['confidentiality']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                doc['confidentiality'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doc['createdAt'] ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showSuccessSnackBar('Opening ${doc['filename']}');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
