import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_chrome.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_details.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_filters.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_states.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_theme.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_tiles.dart';
import 'package:flutter/material.dart';

class DexoProductionScreen extends StatefulWidget {
  const DexoProductionScreen({super.key});

  @override
  State<DexoProductionScreen> createState() => _DexoProductionScreenState();
}

class _DexoProductionScreenState extends State<DexoProductionScreen> {
  bool _isLoading = true;

  List<Map<String, dynamic>> _documentActions = [];

  String _selectedDocType = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadProduction();
  }

  Future<void> _loadProduction() async {
    setState(() => _isLoading = true);

    try {
      final docs = await HeraService.getDocumentActions(limit: 50);

      if (!mounted) return;

      setState(() {
        _documentActions = List<Map<String, dynamic>>.from(
          docs['success'] == true ? (docs['actions'] ?? []) : [],
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _documentActions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadProduction();
  }

  List<Map<String, dynamic>> get _filteredActions {
    return _documentActions.where((action) {
      final details = action['details'] is Map
          ? Map<String, dynamic>.from(action['details'])
          : <String, dynamic>{};

      final docType =
          (details['document'] ??
                  details['doc_type'] ??
                  details['type'] ??
                  action['action_type'] ??
                  '')
              .toString()
              .toLowerCase();

      final createdRaw = action['created_at'] ?? action['createdAt'];
      final createdAt = createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null;

      final matchType =
          _selectedDocType == 'all' || docType.contains(_selectedDocType);

      bool matchDate = true;

      if (_selectedDateRange != null && createdAt != null) {
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );

        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );

        matchDate =
            createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            createdAt.isBefore(end.add(const Duration(seconds: 1)));
      }

      return matchType && matchDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final actions = _filteredActions;

    return Scaffold(
      backgroundColor: DexoProductionTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            DexoProductionHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: AppLoadingIndicator(
                        color: DexoProductionTheme.dark,
                      ),
                    )
                  : RefreshIndicator(
                      color: DexoProductionTheme.dark,
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        children: [
                          DexoProductionFilterBar(
                            selectedDocType: _selectedDocType,
                            selectedDateRange: _selectedDateRange,
                            onSelectDocType: (type) {
                              setState(() => _selectedDocType = type);
                            },
                            onPickDate: _pickDateRange,
                            onClear: () {
                              setState(() {
                                _selectedDocType = 'all';
                                _selectedDateRange = null;
                              });
                            },
                          ),
                          const SizedBox(height: 22),
                          const DexoProductionSectionTitle('PRODUCTION LOGS'),
                          const SizedBox(height: 12),
                          if (actions.isEmpty)
                            const DexoProductionEmptyState()
                          else
                            ...actions.map(
                              (action) => DexoProductionTile(
                                action: action,
                                onTap: () => _showDocumentDetails(action),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DexoProductionTheme.dark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DexoProductionTheme.dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _showDocumentDetails(Map<String, dynamic> action) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DexoProductionDetailsSheet(action: action),
    );
  }
}
