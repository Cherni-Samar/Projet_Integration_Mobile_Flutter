import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_campaign_history_tab.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_form.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final String _selectedFrequency = '3days';
  List<Map<String, dynamic>> _campaignHistory = [];

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
        backgroundColor: EchoProductMarketingTheme.bg,
        appBar: AppBar(
          backgroundColor: EchoProductMarketingTheme.violet,
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
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
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
          const EchoProductMarketingHeader(),
          const SizedBox(height: 24),
          EchoProductUrlInput(
            controller: _urlController,
            isLoading: _isLoading,
            onAnalyze: _scrapeProduct,
          ),
          const SizedBox(height: 24),
          if (_isScraped && _productData != null) ...[
            EchoProductPreview(productData: _productData),
            const SizedBox(height: 24),
            EchoStartCampaignButton(
              isStartingCampaign: _isStartingCampaign,
              onStart: _startCampaign,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return EchoCampaignHistoryTab(
      isLoading: _isLoadingHistory,
      campaigns: _campaignHistory,
      onRefresh: _loadCampaignHistory,
      onManageCampaign: () {
        _showSnackBar('Campaign management coming soon!');
      },
    );
  }
}
