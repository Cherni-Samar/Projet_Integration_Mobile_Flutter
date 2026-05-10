import 'package:e_team/data/services/dexo_service.dart';
import 'package:e_team/presentation/widgets/documents/document_category_app_bar.dart';
import 'package:e_team/presentation/widgets/documents/document_category_card.dart';
import 'package:e_team/presentation/widgets/documents/document_category_dialogs.dart';
import 'package:e_team/presentation/widgets/documents/document_category_states.dart';
import 'package:e_team/presentation/widgets/documents/document_category_theme.dart';
import 'package:flutter/material.dart';

class DocumentCategoryPage extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const DocumentCategoryPage({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<DocumentCategoryPage> createState() => _DocumentCategoryPageState();
}

class _DocumentCategoryPageState extends State<DocumentCategoryPage> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;

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
      setState(() => _isLoading = false);
    }
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
        backgroundColor: DocumentCategoryTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDocumentDetails(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => DocumentDetailsDialog(
        document: document,
        category: widget.category,
        categoryColor: widget.categoryColor,
        categoryIcon: widget.categoryIcon,
        onViewContent: () => _viewDocumentContent(document),
      ),
    );
  }

  Future<void> _viewDocumentContent(Map<String, dynamic> document) async {
    final navigator = Navigator.of(context);

    navigator.pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await DexoService.getDocumentContent(
        documentId: document['id'],
      );

      if (!mounted) return;
      navigator.pop();

      if (result['success'] == true) {
        _showDocumentContentDialog(document, result['content']);
      } else {
        _showErrorSnackBar(
          result['error'] ?? 'Failed to load document content',
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      _showErrorSnackBar('Error loading document content: $e');
    }
  }

  void _showDocumentContentDialog(
    Map<String, dynamic> document,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => DocumentContentDialog(
        document: document,
        content: content,
        category: widget.category,
        categoryColor: widget.categoryColor,
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
        title: DocumentCategoryAppBarTitle(
          category: widget.category,
          categoryIcon: widget.categoryIcon,
          documentCount: _documents.length,
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
            ? DocumentCategoryEmptyState(
                category: widget.category,
                categoryColor: widget.categoryColor,
                categoryIcon: widget.categoryIcon,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _documents.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _documents.length) {
                    if (_hasMore && !_isLoading) {
                      _loadDocuments();
                    }
                    return _isLoading
                        ? const DocumentLoadingMoreIndicator()
                        : const SizedBox.shrink();
                  }

                  return DocumentCard(
                    document: _documents[index],
                    categoryColor: widget.categoryColor,
                    onTap: () => _showDocumentDetails(_documents[index]),
                  );
                },
              ),
      ),
    );
  }
}
