import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/hr_agent_service.dart';

class HeraHistoryPage extends StatefulWidget {
  final bool isDark;
  final List<Map<String, dynamic>>? actions; // ✅ AJOUTE CETTE LIGNE

  // ✅ MODIFIE LE CONSTRUCTEUR ICI
  const HeraHistoryPage({super.key, required this.isDark, this.actions});

  @override
  State<HeraHistoryPage> createState() => _HeraHistoryPageState();
}

class _HeraHistoryPageState extends State<HeraHistoryPage> {
  List<Map<String, dynamic>> _actions = [];
  bool _loading = true;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    // ✅ MODIFICATION ICI
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      _actions = List<Map<String, dynamic>>.from(widget.actions!);
      _loading = false;
    } else {
      _loadActions();
    }
  }
  /// Extrait l'ID MongoDB qu'il soit String ou Map {"$oid": "xxx"}
  String? _extractId(dynamic id) {
    if (id == null) return null;
    if (id is String) return id;
    if (id is Map) return id['\$oid']?.toString() ?? id['_id']?.toString();
    return id.toString();
  }

  Future<void> _loadActions({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _actions = [];
      });
    }
    if (_loadingMore) return;
    setState(() {
      _loading = _actions.isEmpty;
      _loadingMore = true;
    });
    try {
      final result = await HrAgentService.getAllActions(page: _page, limit: 20);
      if (result['success'] == true) {
        final newActions = List<Map<String, dynamic>>.from(result['actions'] ?? []);
        setState(() {
          _actions.addAll(newActions);
          _hasMore = _page < (result['total_pages'] ?? 1);
          _loading = false;
          _loadingMore = false;
        });
      } else {
        setState(() { _loading = false; _loadingMore = false; });
      }
    } catch (e) {
      setState(() { _loading = false; _loadingMore = false; });
    }
  }

  Future<void> _deleteAction(int index, String? actionId) async {
    if (index >= _actions.length) return;
    final removed = _actions[index];
    setState(() => _actions.removeAt(index));

    if (actionId != null && actionId.isNotEmpty) {
      try {
        await HrAgentService.deleteAction(actionId);
      } catch (e) {
        if (mounted) {
          setState(() => _actions.insert(index, removed));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la suppression')),
          );
          return;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Action supprimée'),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Map<String, dynamic> _getConfig(Map<String, dynamic> action) {
    switch (action['action_type']) {
      case 'onboarding_started':
        return {'icon': Icons.person_add_rounded, 'color': const Color(
            0xFFCCFF00), 'label': 'Onboarding démarré', 'badge': 'NOUVEAU'};
      case 'onboarding_completed':
        return {'icon': Icons.check_circle_rounded, 'color': const Color(0xFF10B981), 'label': 'Onboarding complété', 'badge': 'ACTIF'};
      case 'leave_approved':
        return {'icon': Icons.event_available_rounded, 'color': const Color(0xFF10B981), 'label': 'Congé approuvé', 'badge': 'APPROUVÉ'};
      case 'leave_refused':
        return {'icon': Icons.event_busy_rounded, 'color': const Color(0xFFEF4444), 'label': 'Congé refusé', 'badge': 'REFUSÉ'};
      case 'offboarding_started':
        return {'icon': Icons.logout_rounded, 'color': const Color(0xFFF59E0B), 'label': 'Offboarding démarré', 'badge': 'DÉPART'};
      case 'offboarding_completed':
        return {'icon': Icons.exit_to_app_rounded, 'color': const Color(0xFFEF4444), 'label': 'Offboarding complété', 'badge': 'INACTIF'};
      case 'promotion':
        return {'icon': Icons.trending_up_rounded, 'color': const Color(0xFFA855F7), 'label': 'Promotion', 'badge': 'PROMU'};
      case 'absence_alert':
        return {'icon': Icons.warning_amber_rounded, 'color': const Color(0xFFF59E0B), 'label': 'Alerte absences', 'badge': 'ALERTE'};
      default:
        return {'icon': Icons.info_outline_rounded, 'color': const Color(0xFFA855F7), 'label': 'Action Hera', 'badge': 'INFO'};
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return DateFormat('d MMM yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFCCFF00).withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique complet',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Toutes les actions Hera',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFCCFF00).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_actions.length}',
                      style: const TextStyle(
                        color: Color(0xFFCCFF00),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
              )
                  : _actions.isEmpty
                  ? _buildEmpty(isDark)
                  : RefreshIndicator(
                onRefresh: () => _loadActions(refresh: true),
                color: const Color(0xFFCCFF00),
                backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
                        _hasMore && !_loadingMore) {
                      _page++;
                      _loadActions();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _actions.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _actions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Color(0xFFCCFF00),
                            ),
                          ),
                        );
                      }

                      final action = _actions[index];
                      final config = _getConfig(action);
                      final employeeName = action['employee_name'] ?? 'Employé';
                      final createdAt = action['created_at'] != null
                          ? DateTime.tryParse(action['created_at'].toString())
                          : null;
                      final actionId = _extractId(action['_id']);

                      return Dismissible(
                        key: Key('hist_${actionId}_$index'),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) => _deleteAction(index, actionId),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFEF4444), size: 20),
                              SizedBox(width: 8),
                              Text('Supprimer',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141414) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (config['color'] as Color).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: (config['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  config['icon'] as IconData,
                                  color: isDark ? Colors.white : Colors.black,                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employeeName,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      config['label'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCCFF00).withOpacity(0.6),                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      config['badge'] as String,
                                      style: TextStyle(
                                        color: Colors.black, // ✅ TOUJOURS NOIR
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (createdAt != null) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      _timeAgo(createdAt),
                                      style: TextStyle(
                                        color: isDark ? Colors.white30 : Colors.black38,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.history_rounded, color: Color(0xFF000000), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune action',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'L\'historique apparaîtra ici',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}