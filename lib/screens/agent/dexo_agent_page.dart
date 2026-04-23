import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../services/dexo_service.dart';
import '../../test/multi_agent_scenario_test.dart';
import '../../services/agent_service.dart';
import '../documents/document_category_page.dart';

class DexoAgentPage extends StatefulWidget {
  const DexoAgentPage({Key? key}) : super(key: key);

  @override
  State<DexoAgentPage> createState() => _DexoAgentPageState();
}

class _DexoAgentPageState extends State<DexoAgentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Theme colors for better UX
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _documentTypeController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _classifyContentController = TextEditingController();
  final TextEditingController _classifyFilenameController = TextEditingController();
  final TextEditingController _documentIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _auditUserIdController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;
  List<Map<String, dynamic>> _searchHistory = [];
  Map<String, dynamic>? _agentStatus;
  // Upload functionality removed - file upload variables disabled
  String? _selectedEventType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this); // Increased from 5 to 8 tabs
    _loadAgentStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _documentTypeController.dispose();
    _requirementsController.dispose();
    _classifyContentController.dispose();
    _classifyFilenameController.dispose();
    _documentIdController.dispose();
    _userIdController.dispose();
    _auditUserIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAgentStatus() async {
    try {
      final status = await DexoService.getHealth();
      setState(() {
        _agentStatus = status;
      });
    } catch (e) {
      print('Error loading agent status: $e');
    }
  }

  // Upload functionality removed - file picker methods disabled

  Future<void> _classifyDocument() async {
    // Only text-based classification is supported now
    if (_classifyFilenameController.text.trim().isEmpty ||
        _classifyContentController.text.trim().isEmpty) {
      _showErrorDialog('Error', 'Please fill in filename and content');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Handle text-based classification only
      final classifyResult = await DexoService.classifyDocument(
        filename: _classifyFilenameController.text.trim(),
        content: _classifyContentController.text.trim(),
        metadata: {
          'source': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
          'upload_type': 'text',
        },
      );

      setState(() {
        _lastResult = classifyResult;
        _isLoading = false;
      });

      _showResultDialog('Document Classification', classifyResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Classification Error', e.toString());
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final searchResult = await DexoService.intelligentSearch(
        query: _searchController.text.trim(),
        userRole: 'employee', // Replace with actual user role
        context: {
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'mobile_app',
        },
      );

      setState(() {
        _lastResult = searchResult;
        _searchHistory.insert(0, {
          'query': _searchController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
          'results': searchResult['totalFound'] ?? 0,
        });
        _isLoading = false;
      });

      _showResultDialog('Search Results', searchResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Search Error', e.toString());
    }
  }

  Future<void> _generateDocument() async {
    if (_documentTypeController.text.trim().isEmpty ||
        _requirementsController.text.trim().isEmpty) {
      _showErrorDialog('Error', 'Please fill in document type and requirements');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final generateResult = await DexoService.generateDocument(
        documentType: _documentTypeController.text.trim(),
        requirements: _requirementsController.text.trim(),
        data: {
          'generatedBy': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _lastResult = generateResult;
        _isLoading = false;
      });

      _showResultDialog('Document Generated', generateResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Generation Error', e.toString());
    }
  }

  Future<void> _checkExpirations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final expirationResult = await DexoService.checkExpirations();

      setState(() {
        _lastResult = expirationResult;
        _isLoading = false;
      });

      _showResultDialog('Expiration Check', expirationResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Expiration Check Error', e.toString());
    }
  }

  void _showResultDialog(String title, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced Header with gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: result['success'] == true 
                        ? [successColor, successColor.withOpacity(0.8)]
                        : [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        result['success'] == true ? Icons.check_circle_outline : Icons.info_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result['success'] == true 
                                ? 'Operation completed successfully'
                                : 'View operation details',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              
              // Enhanced Content with better formatting
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Success indicator
                      if (result['success'] == true) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: successColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: successColor, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Success',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Enhanced result display
                      _buildEnhancedResultDisplay(result),
                    ],
                  ),
                ),
              ),
              
              // Enhanced Footer with more actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Close button
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    
                    // Right side - Action buttons
                    Row(
                      children: [
                        // Save button (only for classification results)
                        if (title == 'Document Classification' && result['success'] == true && result['classification'] != null) ...[
                          ElevatedButton.icon(
                            onPressed: () => _saveClassifiedDocument(result),
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Copy button
                        ElevatedButton.icon(
                          onPressed: () => _copyResultToClipboard(result),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
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

  void _showErrorDialog(String title, String error) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: warningColor, // Changed from errorColor to warningColor (orange)
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.error, color: Colors.white, size: 24),
                    ),
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
                          ),
                          const Text(
                            'An error occurred during the operation',
                            style: TextStyle(
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: warningColor.withOpacity(0.1), // Changed from errorColor to warningColor
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: warningColor.withOpacity(0.3)), // Changed from errorColor to warningColor
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: warningColor, size: 20), // Changed from errorColor to warningColor
                            const SizedBox(width: 8),
                            const Text(
                              'Error Details',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Report error functionality could be added here
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.bug_report, size: 16),
                      label: const Text('Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warningColor, // Changed from errorColor to warningColor
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  String _formatResult(Map<String, dynamic> result) {
    // Format the result for display
    StringBuffer buffer = StringBuffer();
    
    result.forEach((key, value) {
      if (key == 'timestamp' || key == 'success') return;
      
      buffer.writeln('$key: ${_formatValue(value)}');
    });
    
    return buffer.toString();
  }

  String _formatValue(dynamic value) {
    if (value is Map) {
      return value.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
    } else if (value is List) {
      return value.join(', ');
    } else {
      return value.toString();
    }
  }

  // Enhanced result display with better formatting and colors
  Widget _buildEnhancedResultDisplay(Map<String, dynamic> result) {
    if (result.containsKey('classification')) {
      return _buildClassificationDisplay(result['classification']);
    } else if (result.containsKey('results')) {
      return _buildSearchResultsDisplay(result['results']);
    } else {
      return _buildGenericResultDisplay(result);
    }
  }

  Widget _buildClassificationDisplay(Map<String, dynamic> classification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Section
        _buildResultCard(
          'Category',
          classification['category']?.toString() ?? 'Unknown',
          Icons.category,
          primaryColor,
        ),
        const SizedBox(height: 12),
        
        // Subcategory Section
        if (classification['subcategory'] != null)
          _buildResultCard(
            'Subcategory',
            classification['subcategory'].toString(),
            Icons.subdirectory_arrow_right,
            secondaryColor,
          ),
        const SizedBox(height: 12),
        
        // Security Level Section
        _buildResultCard(
          'Security Level',
          classification['confidentialityLevel']?.toString() ?? 'Public',
          Icons.security,
          _getSecurityColor(classification['confidentialityLevel']?.toString()),
        ),
        const SizedBox(height: 12),
        
        // Suggested Name Section
        if (classification['suggestedName'] != null)
          _buildResultCard(
            'Suggested Name',
            classification['suggestedName'].toString(),
            Icons.drive_file_rename_outline,
            accentColor,
          ),
        const SizedBox(height: 12),
        
        // Tags Section
        if (classification['tags'] != null && classification['tags'] is List)
          _buildTagsDisplay(classification['tags']),
        const SizedBox(height: 12),
        
        // Confidence Section
        if (classification['confidence'] != null)
          _buildConfidenceDisplay(classification['confidence']),
        const SizedBox(height: 12),
        
        // Access Roles Section
        if (classification['accessRoles'] != null && classification['accessRoles'] is List)
          _buildAccessRolesDisplay(classification['accessRoles']),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsDisplay(List tags) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceDisplay(dynamic confidence) {
    double confidenceValue = 0.0;
    if (confidence is num) {
      confidenceValue = confidence.toDouble();
    } else if (confidence is String) {
      confidenceValue = double.tryParse(confidence) ?? 0.0;
    }
    
    Color confidenceColor = confidenceValue >= 0.8 ? successColor : 
                           confidenceValue >= 0.6 ? warningColor : errorColor;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: confidenceColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics, color: confidenceColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence Level',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: confidenceValue,
                        backgroundColor: confidenceColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(confidenceValue * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: confidenceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRolesDisplay(List roles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Access Roles',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.map((role) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                role.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsDisplay(List results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${results.length} found)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...results.take(5).map((result) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            result.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildGenericResultDisplay(Map<String, dynamic> result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        _formatResult(result),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
          color: Colors.black87,
        ),
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

  // Copy result to clipboard
  void _copyResultToClipboard(Map<String, dynamic> result) {
    final text = _formatResult(result);
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Result copied to clipboard'),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Save classified document to database
  Future<void> _saveClassifiedDocument(Map<String, dynamic> result) async {
    try {
      // Close the current dialog first
      Navigator.of(context).pop();
      
      // Show loading
      setState(() {
        _isLoading = true;
      });

      // Extract classification data
      final classification = result['classification'] as Map<String, dynamic>;
      final filename = _classifyFilenameController.text.trim();
      final content = _classifyContentController.text.trim();
      
      // Call the save service
      final saveResult = await DexoService.saveClassifiedDocument(
        filename: filename,
        content: content,
        classification: classification,
        userId: 'user1', // Replace with actual user ID
        metadata: {
          'source': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
          'originalClassification': classification,
        },
      );

      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      if (saveResult['success'] == true) {
        _showSaveSuccessDialog(saveResult);
      } else {
        _showErrorDialog('Save Error', saveResult['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Save Error', e.toString());
    }
  }

  void _showSaveSuccessDialog(Map<String, dynamic> saveResult) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [successColor, successColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Saved',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Document successfully saved to database',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Success indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: successColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.save, color: successColor, size: 24),
                                const SizedBox(width: 12),
                                const Text(
                                  'Save Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (saveResult['filename'] != null) ...[
                              Text(
                                'Filename: ${saveResult['filename']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (saveResult['documentId'] != null) ...[
                              Text(
                                'Document ID: ${saveResult['documentId']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (saveResult['classification'] != null) ...[
                              Text(
                                'Category: ${saveResult['classification']['category'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Security Level: ${saveResult['classification']['confidentialityLevel'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'You can find this document in the appropriate category section.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to dashboard to see categories
                        _tabController.animateTo(0);
                      },
                      icon: const Icon(Icons.dashboard, size: 18),
                      label: const Text('View Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  // Upload functionality removed - upload methods disabled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('assets/images/dexo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dexo Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Document Security Manager', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ],
        ),
        actions: [
          // Add refresh button
          IconButton(
            onPressed: _loadAgentStatus,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Agent Status',
          ),
          // Add settings button
          IconButton(
            onPressed: () {
              // Settings functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings coming soon!'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: accentColor,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard, size: 20),
                  text: 'Dashboard',
                ),
                Tab(
                  icon: Icon(Icons.auto_awesome, size: 20),
                  text: 'Classify',
                ),
                Tab(
                  icon: Icon(Icons.search, size: 20),
                  text: 'Search',
                ),
                Tab(
                  icon: Icon(Icons.create_new_folder, size: 20),
                  text: 'Generate',
                ),
                Tab(
                  icon: Icon(Icons.schedule_outlined, size: 20),
                  text: 'Expiration',
                ),
                Tab(
                  icon: Icon(Icons.security, size: 20),
                  text: 'Security',
                ),
                Tab(
                  icon: Icon(Icons.share_outlined, size: 20),
                  text: 'Sharing',
                ),
                Tab(
                  icon: Icon(Icons.history, size: 20),
                  text: 'Audit',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildClassifyTab(),
              _buildSearchTab(),
              _buildGenerateTab(),
              _buildExpirationTab(),
              _buildSecurityTab(),
              _buildSharingTab(),
              _buildAuditTab(),
            ],
          ),
          // Global loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Add floating action button for quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildQuickActionsBottomSheet(),
          );
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.flash_on),
        label: const Text('Quick Actions'),
      ),
    );
  }

  Widget _buildQuickActionsBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionTile(
                icon: Icons.auto_awesome,
                title: 'Classify',
                subtitle: 'Auto-classify documents',
                color: warningColor,
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
              ),
              _buildQuickActionTile(
                icon: Icons.search,
                title: 'Search',
                subtitle: 'Find documents',
                color: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(2);
                },
              ),
              _buildQuickActionTile(
                icon: Icons.security,
                title: 'Security Scan',
                subtitle: 'Run security check',
                color: errorColor,
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(5);
                  _performSecurityScan();
                },
              ),
              _buildQuickActionTile(
                icon: Icons.schedule,
                title: 'Check Expiry',
                subtitle: 'Monitor expirations',
                color: warningColor,
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(4);
                  _checkExpirations();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent Status Card
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/images/dexo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agent Dexo',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (_agentStatus != null) ...[
                            Text(
                              _agentStatus!['mission'] ?? 'Administrative Document Agent',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: successColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: successColor, size: 16),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Operational',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.auto_awesome,
                  title: 'Classify',
                  subtitle: 'Auto-classify documents',
                  color: warningColor,
                  onTap: () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.search,
                  title: 'Search',
                  subtitle: 'Smart document search',
                  color: primaryColor,
                  onTap: () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Security monitoring',
                  color: errorColor,
                  onTap: () => _tabController.animateTo(5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.share,
                  title: 'Share',
                  subtitle: 'Secure sharing',
                  color: accentColor,
                  onTap: () => _tabController.animateTo(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Document Categories
          const Text(
            'Document Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...DexoService.getDocumentCategories().map((category) => 
            _buildCategoryCard(category)
          ),
          const SizedBox(height: 20),

          // Security Levels
          const Text(
            'Security Levels',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...DexoService.getAdvancedConfidentialityLevels().entries.map((entry) {
            final level = entry.key;
            final config = entry.value;
            return _buildSecurityLevelCard(level, config);
          }),
          const SizedBox(height: 20),

          // Multi-Agent Testing
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Multi-Agent Testing',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Test complex multi-agent collaboration scenarios with advanced AI workflows.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MultiAgentScenarioTest(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Multi-Agent Scenario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
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
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    final categoryIcons = {
      'contrats': Icons.description,
      'factures': Icons.receipt,
      'rapports': Icons.analytics,
      'presentations': Icons.slideshow,
      'juridique': Icons.gavel,
      'rh': Icons.people,
      'technique': Icons.engineering,
      'marketing': Icons.campaign,
      'finance': Icons.account_balance,
      'autre': Icons.folder,
    };

    final categoryColors = {
      'contrats': Colors.blue,
      'factures': Colors.green,
      'rapports': Colors.orange,
      'presentations': Colors.purple,
      'juridique': Colors.red,
      'rh': Colors.teal,
      'technique': Colors.indigo,
      'marketing': Colors.pink,
      'finance': Colors.amber,
      'autre': Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openCategoryPage(category, categoryColors[category] ?? Colors.grey, categoryIcons[category] ?? Icons.folder),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (categoryColors[category] ?? Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcons[category] ?? Icons.folder,
                  color: categoryColors[category] ?? Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Document category: $category',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add file button
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (categoryColors[category] ?? Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: categoryColors[category] ?? Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategoryPage(String category, Color categoryColor, IconData categoryIcon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentCategoryPage(
          category: category,
          categoryColor: categoryColor,
          categoryIcon: categoryIcon,
        ),
      ),
    );
  }

  Widget _buildSecurityLevelCard(String level, Map<String, dynamic> config) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.security,
              color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      level.toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Level ${config['level']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Roles: ${config['roles'].join(', ')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_awesome, color: warningColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Document Classification',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Automatically classify documents using AI to determine category, confidentiality level, and access permissions.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                
                // Text Input Mode (File upload removed)
                _buildModernTextField(
                  controller: _classifyFilenameController,
                  label: 'Document Filename',
                  hint: 'e.g., contract_2024.pdf',
                  icon: Icons.insert_drive_file,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  controller: _classifyContentController,
                  label: 'Document Content',
                  hint: 'Paste or type the document content here...',
                  icon: Icons.description,
                  maxLines: 6,
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _classifyDocument,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isLoading ? 'Classifying...' : 'Classify Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            title: 'Classification Features',
            icon: Icons.checklist,
            color: warningColor,
            features: [
              '📂 Automatic categorization',
              '🔒 Confidentiality level detection',
              '🏷️ Smart tag extraction',
              '📅 Expiration date identification',
              '📝 Intelligent naming suggestions',
              '👥 Access role recommendations',
              '📄 PDF & Image support',
              '🤖 AI-powered analysis',
            ],
          ),
        ],
      ),
    );
  }

  // File icon method removed - upload functionality disabled

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> features,
  }) {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.search, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Intelligent Search',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Search documents using natural language queries with AI-powered understanding.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Query',
                      hintText: 'e.g., "contracts signed last month"',
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: primaryColor),
                        onPressed: _performSearch,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performSearch,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? 'Searching...' : 'Search Documents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_searchHistory.isNotEmpty) ...[
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent Searches',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(_searchHistory.take(5).map((search) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _searchController.text = search['query'];
                        _performSearch();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    search['query'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${search['results']} results • ${DateTime.parse(search['timestamp']).toLocal().toString().split('.')[0]}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),
                  ))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.create_new_folder, color: successColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Document Generation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate professional documents automatically using AI with customizable templates and requirements.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Document Type',
                      prefixIcon: Icon(Icons.category, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    isExpanded: true,
                    items: DexoService.getSupportedDocumentTypes()
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.replaceAll('_', ' ').toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _documentTypeController.text = value ?? '';
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  controller: _requirementsController,
                  label: 'Requirements & Content',
                  hint: 'Describe what the document should contain...',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateDocument,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(_isLoading ? 'Generating...' : 'Generate Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            title: 'Generation Features',
            icon: Icons.auto_fix_high,
            color: successColor,
            features: [
              '📄 Professional document templates',
              '🤖 AI-powered content generation',
              '📝 Customizable requirements',
              '🎨 Multiple format support',
              '🌐 Multi-language generation',
              '⚡ Instant document creation',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.schedule_outlined, color: warningColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Expiration Monitoring',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor document expiration dates and receive proactive alerts for renewal requirements.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkExpirations,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.schedule_outlined),
                    label: Text(_isLoading ? 'Checking...' : 'Check Document Expirations'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performExpirationScan,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.scanner),
                    label: Text(_isLoading ? 'Scanning...' : 'Run Full Expiration Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            title: 'Expiration Management Features',
            icon: Icons.schedule,
            color: warningColor,
            features: [
              '📅 Automatic expiration detection',
              '⚠️ Proactive alerts before expiration',
              '📧 Email notifications to responsible parties',
              '🔄 Renewal workflow triggers',
              '📊 Compliance status tracking',
              '🤖 Auto-renewal capabilities',
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _performExpirationScan() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final scanResult = await DexoService.performExpirationScan();

      setState(() {
        _lastResult = scanResult;
        _isLoading = false;
      });

      _showResultDialog('Expiration Scan Results', scanResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Expiration Scan Error', e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔒 SECURITY TAB - Advanced Security Dashboard
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Security Dashboard Card
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.security, color: errorColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Security Dashboard',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor security threats, perform scans, and analyze system vulnerabilities in real-time.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _performSecurityScan,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.scanner, size: 18),
                        label: Text(_isLoading ? 'Scanning...' : 'Security Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _getSecurityMetrics,
                        icon: const Icon(Icons.analytics, size: 18),
                        label: const Text('Metrics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: warningColor,
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // RBAC Management Card
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Role-Based Access Control',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage document access permissions by user roles and confidentiality levels.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...DexoService.getAdvancedConfidentialityLevels().entries.map((entry) {
                  final level = entry.key;
                  final config = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.security,
                            color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    level.toUpperCase(),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'L${config['level']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(int.parse(config['color'].replaceAll('#', '0xFF'))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Roles: ${config['roles'].join(', ')}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Behavioral Analysis Card
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.purple, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Behavioral Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Detect suspicious user behavior patterns and potential security threats.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  controller: _userIdController,
                  label: 'User ID to Analyze',
                  hint: 'e.g., user1',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeSuspiciousPatterns,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Analyze User Behavior'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔗 SHARING TAB - Secure Document Sharing
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSharingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.share_outlined, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Secure Document Sharing',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create secure sharing links with advanced access controls and monitoring.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                _buildModernTextField(
                  controller: _documentIdController,
                  label: 'Document ID',
                  hint: 'e.g., doc_test_1',
                  icon: Icons.insert_drive_file,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  controller: _userIdController,
                  label: 'User ID',
                  hint: 'e.g., user1',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _createSecureShareLink,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.link),
                    label: Text(_isLoading ? 'Creating...' : 'Create Secure Share Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sharing Features Card
          _buildFeatureCard(
            title: 'Secure Sharing Features',
            icon: Icons.security,
            color: accentColor,
            features: [
              '🔗 Temporary secure links with expiration',
              '🔒 Password protection for sensitive documents',
              '📊 Download limits and tracking',
              '🌐 IP address restrictions',
              '📧 Access notifications',
              '📜 Complete access logging',
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📜 AUDIT TAB - Comprehensive Audit Logging
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAuditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.history, color: successColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Audit Logs & Monitoring',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Track all document activities with comprehensive audit logging and real-time monitoring.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _auditUserIdController,
                        label: 'User ID (optional)',
                        hint: 'e.g., user1',
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Event Type',
                            prefixIcon: Icon(Icons.filter_list, color: primaryColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          isExpanded: true,
                          items: ['All', ...DexoService.getSecurityEventTypes()]
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _selectedEventType = value == 'All' ? null : value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadAuditLogs,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? 'Loading...' : 'Load Audit Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Audit Features Card
          _buildFeatureCard(
            title: 'Audit Logging Features',
            icon: Icons.analytics,
            color: successColor,
            features: [
              '📝 Complete access logging',
              '🔍 Advanced filtering and search',
              '📊 Security event analytics',
              '⚠️ Suspicious behavior detection',
              '📈 Real-time monitoring',
              '🔒 Tamper-proof audit trail',
            ],
          ),

          const SizedBox(height: 16),

          // Quick Audit Actions
          _buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Quick Audit Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.warning,
                        label: 'Security Alerts',
                        color: warningColor, // Changed from errorColor to warningColor (orange)
                        onTap: () => _loadAuditLogsWithFilter('security_alert'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.download,
                        label: 'Downloads',
                        color: primaryColor,
                        onTap: () => _loadAuditLogsWithFilter('document_download'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.share,
                        label: 'Shares',
                        color: accentColor,
                        onTap: () => _loadAuditLogsWithFilter('document_share'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.login,
                        label: 'Access',
                        color: warningColor,
                        onTap: () => _loadAuditLogsWithFilter('document_access'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 NEW METHOD IMPLEMENTATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _performSecurityScan() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final scanResult = await DexoService.performSecurityScan();

      setState(() {
        _lastResult = scanResult;
        _isLoading = false;
      });

      _showResultDialog('Security Scan Results', scanResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Security Scan Error', e.toString());
    }
  }

  Future<void> _getSecurityMetrics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final metricsResult = await DexoService.getSecurityMetrics();

      setState(() {
        _lastResult = metricsResult;
        _isLoading = false;
      });

      _showResultDialog('Security Metrics', metricsResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Security Metrics Error', e.toString());
    }
  }

  Future<void> _analyzeSuspiciousPatterns() async {
    if (_userIdController.text.trim().isEmpty) {
      _showErrorDialog('Error', 'Please enter a User ID');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final analysisResult = await DexoService.analyzeSuspiciousPatterns(
        userId: _userIdController.text.trim(),
      );

      setState(() {
        _lastResult = analysisResult;
        _isLoading = false;
      });

      _showResultDialog('Behavioral Analysis', analysisResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Behavioral Analysis Error', e.toString());
    }
  }

  Future<void> _createSecureShareLink() async {
    if (_documentIdController.text.trim().isEmpty || _userIdController.text.trim().isEmpty) {
      _showErrorDialog('Error', 'Please fill in Document ID and User ID');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final shareResult = await DexoService.createSecureShareLink(
        documentId: _documentIdController.text.trim(),
        userId: _userIdController.text.trim(),
        options: {
          'maxDownloads': 5,
          'requirePassword': false,
          'notifyOnAccess': true,
        },
      );

      setState(() {
        _lastResult = shareResult;
        _isLoading = false;
      });

      _showResultDialog('Secure Share Link Created', shareResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Secure Share Error', e.toString());
    }
  }

  Future<void> _loadAuditLogs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final auditResult = await DexoService.getAuditLogs(
        userId: _auditUserIdController.text.trim().isEmpty ? null : _auditUserIdController.text.trim(),
        eventType: _selectedEventType,
        limit: 50,
      );

      setState(() {
        _lastResult = auditResult;
        _isLoading = false;
      });

      _showResultDialog('Audit Logs', auditResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Audit Logs Error', e.toString());
    }
  }

  Future<void> _loadAuditLogsWithFilter(String eventType) async {
    try {
      setState(() {
        _isLoading = true;
        _selectedEventType = eventType;
      });

      final auditResult = await DexoService.getAuditLogs(
        userId: _auditUserIdController.text.trim().isEmpty ? null : _auditUserIdController.text.trim(),
        eventType: eventType,
        limit: 50,
      );

      setState(() {
        _lastResult = auditResult;
        _isLoading = false;
      });

      _showResultDialog('Audit Logs - ${eventType.replaceAll('_', ' ').toUpperCase()}', auditResult);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Audit Logs Error', e.toString());
    }
  }
}