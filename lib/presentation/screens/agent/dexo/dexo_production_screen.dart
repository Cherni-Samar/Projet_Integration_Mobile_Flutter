import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/data/services/hera_service.dart';

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

  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF64748B);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _green = Color(0xFF16A34A);

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
    } catch (e) {
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _dark))
                  : RefreshIndicator(
                      color: _dark,
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        children: [
                          _buildFilterBar(),
                          const SizedBox(height: 22),
                          _sectionTitle('PRODUCTION LOGS'),
                          const SizedBox(height: 12),
                          if (actions.isEmpty)
                            _emptyState()
                          else
                            ...actions.map(_productionTile),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          _roundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Production Hub',
              style: GoogleFonts.plusJakartaSans(
                color: _dark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final dateLabel = _selectedDateRange == null
        ? 'Date'
        : '${_formatShortDate(_selectedDateRange!.start)} → ${_formatShortDate(_selectedDateRange!.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter outputs',
          style: GoogleFonts.plusJakartaSans(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip(
                label: 'All',
                selected: _selectedDocType == 'all',
                onTap: () {
                  setState(() => _selectedDocType = 'all');
                },
              ),
              _filterChip(
                label: 'Attestation',
                selected: _selectedDocType == 'attestation',
                onTap: () {
                  setState(() => _selectedDocType = 'attestation');
                },
              ),
              _filterChip(
                label: 'Bulletin',
                selected: _selectedDocType == 'bulletin',
                onTap: () {
                  setState(() => _selectedDocType = 'bulletin');
                },
              ),
              _filterChip(
                label: dateLabel,
                icon: Icons.calendar_month_rounded,
                selected: _selectedDateRange != null,
                onTap: _pickDateRange,
              ),
              if (_selectedDateRange != null || _selectedDocType != 'all')
                _filterChip(
                  label: 'Clear',
                  icon: Icons.close_rounded,
                  selected: false,
                  onTap: () {
                    setState(() {
                      _selectedDocType = 'all';
                      _selectedDateRange = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _dark : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? _dark : _border),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? Colors.white : _dark),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : _dark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
              primary: _dark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _dark,
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

  Widget _productionTile(Map<String, dynamic> action) {
    final details = action['details'] is Map
        ? Map<String, dynamic>.from(action['details'])
        : <String, dynamic>{};

    final docType =
        details['document'] ??
        details['doc_type'] ??
        details['type'] ??
        action['action_type'] ??
        'DOCUMENT';

    final filename = details['filename'] ?? 'document.pdf';

    final employeeName =
        action['employee_name'] ??
        details['employee_name'] ??
        action['employee_id']?['name'] ??
        'System';

    final reason = details['reason'];
    final date = action['created_at'] ?? action['createdAt'];

    return GestureDetector(
      onTap: () => _showDocumentDetails(action),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.028),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: _dark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docType.toString().toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: _dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filename.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: _blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested by $employeeName',
                    style: GoogleFonts.plusJakartaSans(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (reason != null && reason.toString().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Reason: $reason',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(date.toString()),
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDetails(Map<String, dynamic> action) {
    final details = action['details'] is Map
        ? Map<String, dynamic>.from(action['details'])
        : <String, dynamic>{};

    final employee = action['employee_id'] is Map
        ? Map<String, dynamic>.from(action['employee_id'])
        : <String, dynamic>{};

    final docType = details['document'] ?? 'document';
    final filename = details['filename'] ?? 'document.pdf';
    final reason = details['reason'] ?? '—';
    final date = action['created_at'] ?? action['createdAt'];
    final employeeName = employee['name'] ?? 'System';
    final employeeEmail = employee['email'] ?? '—';
    final department = employee['department'] ?? '—';
    final role = employee['role'] ?? '—';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: _dark,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docType.toString().toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: _dark,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filename.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: _blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _detailRow('Employee', employeeName.toString()),
                _detailRow('Email', employeeEmail.toString()),
                _detailRow('Role', role.toString()),
                _detailRow('Department', department.toString()),
                _detailRow('Reason', reason.toString()),
                _detailRow(
                  'Created at',
                  date != null ? _formatDate(date.toString()) : '—',
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Generated, archived and sent by Hera.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                color: _dark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 44, color: _muted),
          const SizedBox(height: 12),
          Text(
            'No production logs found',
            style: GoogleFonts.plusJakartaSans(
              color: _dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing the filters or swipe down to refresh.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: _dark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _dark, size: 18),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);

    if (parsed == null) return raw;

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year} · '
        '${parsed.hour.toString().padLeft(2, '0')}:'
        '${parsed.minute.toString().padLeft(2, '0')}';
  }
}
