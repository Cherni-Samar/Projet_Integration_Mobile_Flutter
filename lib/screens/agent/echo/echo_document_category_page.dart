import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/echo_service.dart';

class EchoDocumentCategoryPage extends StatefulWidget {
  final String category;
  final String? token;

  const EchoDocumentCategoryPage({
    super.key,
    required this.category,
    this.token,
  });

  @override
  State<EchoDocumentCategoryPage> createState() => _EchoDocumentCategoryPageState();
}

class _EchoDocumentCategoryPageState extends State<EchoDocumentCategoryPage> {
  List<DocumentItem> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedConfidentiality;

  final List<String> _confidentialityLevels = [
    'public',
    'interne',
    'confidentiel',
    'critique'
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EchoService.getDocumentsByCategory(
        category: widget.category,
        confidentialityLevel: _selectedConfidentiality,
        token: widget.token,
      );

      if (response.success) {
        setState(() {
          _documents = response.documents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _viewDocumentContent(DocumentItem document) async {
    try {
      final response = await EchoService.getDocumentContent(
        documentId: document.id,
        token: widget.token,
      );

      if (response.success && response.document != null && mounted) {
        _showDocumentContentDialog(response.document!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.error ?? 'Impossible de charger le contenu'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showDocumentContentDialog(DocumentContent document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      document.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),

              // Document Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Catégorie', document.category, Icons.folder),
                    _buildInfoRow('Confidentialité', document.confidentialityLevel, Icons.security),
                    _buildInfoRow('Type', document.documentType, Icons.description),
                    _buildInfoRow('Urgence', document.urgency, Icons.priority_high),
                    _buildInfoRow('Taille', '${document.size} caractères', Icons.data_usage),
                    _buildInfoRow('Date', _formatDate(document.createdAt), Icons.calendar_today),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary
              if (document.summary.isNotEmpty) ...[
                const Text('📝 Résumé:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(document.summary),
                const SizedBox(height: 12),
              ],

              // Key Topics
              if (document.keyTopics.isNotEmpty) ...[
                const Text('🏷️ Sujets clés:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: document.keyTopics.map((topic) => Chip(
                    label: Text(topic, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue.shade100,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Content
              const Text('📄 Contenu:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      document.content,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: document.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contenu copié dans le presse-papiers')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.deepPurple))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor() {
    switch (widget.category) {
      case 'Commercial': return Colors.blue;
      case 'Finance': return Colors.green;
      case 'Juridique': return Colors.red;
      case 'Marketing': return Colors.orange;
      case 'RH': return Colors.purple;
      case 'Technique': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'Commercial': return Icons.business;
      case 'Finance': return Icons.account_balance;
      case 'Juridique': return Icons.gavel;
      case 'Marketing': return Icons.campaign;
      case 'RH': return Icons.people;
      case 'Technique': return Icons.engineering;
      default: return Icons.folder;
    }
  }

  Color _getConfidentialityColor(String level) {
    switch (level) {
      case 'public': return Colors.green;
      case 'interne': return Colors.blue;
      case 'confidentiel': return Colors.orange;
      case 'critique': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getCategoryIcon(), color: _getCategoryColor()),
            const SizedBox(width: 8),
            Text('${widget.category} - Echo'),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par confidentialité',
            onSelected: (value) {
              setState(() {
                _selectedConfidentiality = value == 'all' ? null : value;
              });
              _loadDocuments();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tous les niveaux'),
              ),
              ..._confidentialityLevels.map((level) => PopupMenuItem(
                value: level,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getConfidentialityColor(level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(level.toUpperCase()),
                  ],
                ),
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter indicator
          if (_selectedConfidentiality != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _getCategoryColor().withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: _getCategoryColor()),
                  const SizedBox(width: 8),
                  Text(
                    'Filtré par: ${_selectedConfidentiality!.toUpperCase()}',
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedConfidentiality = null;
                      });
                      _loadDocuments();
                    },
                    child: Icon(Icons.close, size: 16, color: _getCategoryColor()),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDocuments,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
                : _documents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getCategoryIcon(), size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun document dans ${widget.category}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les documents classifiés par Echo apparaîtront ici',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _documents.length,
                itemBuilder: (context, index) => _buildDocumentCard(_documents[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document) {
    return GestureDetector(
      onTap: () => _viewDocumentContent(document),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description,
                    color: _getCategoryColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(document.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary
            if (document.summary.isNotEmpty) ...[
              Text(
                document.summary,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Confidentiality
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidentialityColor(document.confidentialityLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        size: 12,
                        color: _getConfidentialityColor(document.confidentialityLevel),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        document.confidentialityLevel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getConfidentialityColor(document.confidentialityLevel),
                        ),
                      ),
                    ],
                  ),
                ),

                // Document Type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    document.documentType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),

                // Urgency
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(document.urgency).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 12,
                        color: _getUrgencyColor(document.urgency),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        document.urgency.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getUrgencyColor(document.urgency),
                        ),
                      ),
                    ],
                  ),
                ),

                // Size
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${document.size} chars',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            // Key Topics
            if (document.keyTopics.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: document.keyTopics.take(3).map((topic) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    topic,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.purple,
                    ),
                  ),
                )).toList(),
              ),
            ],

            const SizedBox(height: 8),

            // View button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _viewDocumentContent(document),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Voir le contenu'),
                style: TextButton.styleFrom(
                  foregroundColor: _getCategoryColor(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}