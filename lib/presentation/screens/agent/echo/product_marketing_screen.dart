import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/core/config/api_config.dart';

class ProductMarketingScreen extends StatefulWidget {
  final String? token;

  const ProductMarketingScreen({super.key, this.token});

  @override
  State<ProductMarketingScreen> createState() => _ProductMarketingScreenState();
}

class _ProductMarketingScreenState extends State<ProductMarketingScreen> {
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isScraped = false;
  bool _isStartingCampaign = false;
  bool _isLoadingHistory = false;

  Map<String, dynamic>? _productData;
  String _selectedFrequency = '3days';
  List<Map<String, dynamic>> _campaignHistory = [];

  // Theme colors
  static const violet = Color(0xFF9C27B0);
  static const bg = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0E0E0);
  static const textMain = Color(0xFF1A1A1A);
  static const textMuted = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadCampaignHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaignHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final response = await EchoService.getCampaignHistory(
        limit: 50,
        token: widget.token,
      );

      if (response['success'] == true && response['campaigns'] != null) {
        setState(() {
          _campaignHistory = List<Map<String, dynamic>>.from(
            response['campaigns'],
          );
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (_) {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _scrapeProduct() async {
    if (_urlController.text.trim().isEmpty) {
      _showSnackBar('Please enter a product URL', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _isScraped = false;
      _productData = null;
    });

    try {
      final response = await EchoService.scrapeProduct(
        productUrl: _urlController.text.trim(),
        token: widget.token,
      );

      if (response['success'] == true && response['product'] != null) {
        setState(() {
          _productData = response['product'];
          _isScraped = true;
          _isLoading = false;
        });
        _showSnackBar('Product analyzed successfully!');
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(
          response['error'] ?? 'Failed to analyze product',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _startCampaign() async {
    if (_productData == null) {
      _showSnackBar('Please analyze a product first', isError: true);
      return;
    }

    setState(() => _isStartingCampaign = true);

    try {
      final response = await EchoService.startProductCampaign(
        productUrl: _urlController.text.trim(),
        frequency: _selectedFrequency,
        platforms: ['linkedin'],
        token: widget.token,
      );

      setState(() => _isStartingCampaign = false);

      if (response['success'] == true) {
        _showSnackBar('Campaign started successfully! 🚀');
        // Navigate back after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar(
          response['error'] ?? 'Failed to start campaign',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isStartingCampaign = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: violet,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Product Marketing',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'NEW CAMPAIGN'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildNewCampaignTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildNewCampaignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildUrlInput(),
          const SizedBox(height: 24),
          if (_isScraped && _productData != null) ...[
            _buildProductPreview(),
            const SizedBox(height: 24),
            _buildStartButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [violet, violet.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
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
                  'Automated Marketing',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate posts every 3 days automatically',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: violet, size: 20),
              const SizedBox(width: 8),
              Text(
                'Product URL',
                style: GoogleFonts.inter(
                  color: textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://www.amazon.com/product...',
              hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 13),
              filled: true,
              fillColor: bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: violet, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: GoogleFonts.inter(color: textMain, fontSize: 13),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _scrapeProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Analyze Product',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview() {
    if (_productData == null) return const SizedBox.shrink();

    final title = _productData!['title'] ?? 'Unknown Product';
    final description = _productData!['description'] ?? '';
    final price = _productData!['price'] ?? 'N/A';
    final category = _productData!['category'] ?? 'N/A';
    final images = _productData!['images'] as List? ?? [];
    final features = _productData!['features'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Product Preview',
                style: GoogleFonts.inter(
                  color: textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product Image
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${ApiConfig.baseUrl}/api/echo/image-proxy?url=${Uri.encodeComponent(images[0])}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: violet,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: GoogleFonts.inter(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Product Title
          Text(
            title,
            style: GoogleFonts.inter(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price and Category
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: GoogleFonts.inter(
                    color: violet,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 12,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: GoogleFonts.inter(
                color: textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...features
                .take(3)
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: violet)),
                        Expanded(
                          child: Text(
                            feature.toString(),
                            style: GoogleFonts.inter(
                              color: textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isStartingCampaign ? null : _startCampaign,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isStartingCampaign
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start Marketing Campaign',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HISTORY TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }

    if (_campaignHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: violet.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 48,
                  color: violet.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Campaign History',
                style: GoogleFonts.inter(
                  color: textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your campaign history will appear here',
                style: GoogleFonts.inter(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaignHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _campaignHistory.length,
        itemBuilder: (context, index) {
          final campaign = _campaignHistory[index];
          return _buildHistoryCard(campaign);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> campaign) {
    final productTitle = campaign['productTitle'] ?? 'Unknown Product';
    final productImage = campaign['productImage'];
    final productPrice = campaign['productPrice'] ?? 'N/A';
    final status = campaign['status'] ?? 'unknown';
    final frequency = campaign['frequency'] ?? 'N/A';
    final postsGenerated = campaign['postsGenerated'] ?? 0;
    final createdAt = campaign['createdAt'] != null
        ? DateTime.tryParse(campaign['createdAt'])
        : null;

    Color statusColor;
    String statusText;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'ACTIVE';
        break;
      case 'paused':
        statusColor = Colors.orange;
        statusText = 'PAUSED';
        break;
      case 'stopped':
        statusColor = Colors.red;
        statusText = 'STOPPED';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UNKNOWN';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  productTitle,
                  style: GoogleFonts.inter(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (productImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiConfig.baseUrl}/api/echo/image-proxy?url=${Uri.encodeComponent(productImage)}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: textMuted,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 14, color: violet),
                        const SizedBox(width: 4),
                        Text(
                          productPrice,
                          style: GoogleFonts.inter(
                            color: textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: textMuted),
                        const SizedBox(width: 4),
                        Text(
                          _formatFrequency(frequency),
                          style: GoogleFonts.inter(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.article, size: 14, color: textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '$postsGenerated posts',
                          style: GoogleFonts.inter(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Footer with date
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: border),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: textMuted),
                const SizedBox(width: 4),
                Text(
                  'Created ${_formatDate(createdAt)}',
                  style: GoogleFonts.inter(color: textMuted, fontSize: 10),
                ),
              ],
            ),
          ],

          // Action button for active campaigns
          if (status == 'active') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to campaign details or stop campaign
                  _showSnackBar('Campaign management coming soon!');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: violet,
                  side: BorderSide(color: violet, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Manage Campaign',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Every Day';
      case '3days':
        return 'Every 3 Days';
      case 'weekly':
        return 'Every Week';
      default:
        return frequency;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}
