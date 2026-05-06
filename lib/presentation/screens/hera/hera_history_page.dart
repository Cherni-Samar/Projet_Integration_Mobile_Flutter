import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_team/data/services/hera_service.dart';

class HeraHistoryPage extends StatefulWidget {
  final bool isDark;
  final List<Map<String, dynamic>>? actions;

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

  // ✅ FIX SUPPRESSION : On garde en mémoire les IDs supprimés
  // pour les filtrer même après un refresh
  final Set<String> _deletedIds = {};

  // ─── PALETTE MAUVE HERA ───
  static const _lime = Color(0xFFB57BFF); // Mauve Hera principal
  static const _purple = Color(0xFF7C3AED); // Violet profond secondaire

  @override
  void initState() {
    super.initState();
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      _actions = List<Map<String, dynamic>>.from(widget.actions!);
      _loading = false;
    } else {
      _loadActions();
    }
  }

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
      final result = await HeraService.getAllActions(page: _page, limit: 20);
      if (result['success'] == true) {
        final newActions = List<Map<String, dynamic>>.from(
          result['actions'] ?? [],
        );

        // ✅ FIX : On filtre les actions déjà supprimées localement
        final filtered = newActions.where((a) {
          final id = _extractId(a['_id']);
          return id == null || !_deletedIds.contains(id);
        }).toList();

        setState(() {
          _actions.addAll(filtered);
          // Backward-compatible: new backend returns pagination.pages,
          // old shape returned total_pages at the top level.
          final totalPages =
              result['pagination']?['pages'] ?? result['total_pages'] ?? 1;
          _hasMore = _page < totalPages;
          _loading = false;
          _loadingMore = false;
        });
      } else {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _deleteAction(int index, String? actionId) async {
    if (index >= _actions.length) return;
    final removed = _actions[index];

    // ✅ FIX : On marque l'ID comme supprimé AVANT l'appel API
    if (actionId != null && actionId.isNotEmpty) {
      _deletedIds.add(actionId);
    }

    setState(() => _actions.removeAt(index));

    if (actionId != null && actionId.isNotEmpty) {
      try {
        await HeraService.deleteAction(actionId);
      } catch (e) {
        // ✅ En cas d'erreur API, on annule la suppression locale ET on retire de _deletedIds
        if (mounted) {
          _deletedIds.remove(actionId);
          setState(() => _actions.insert(index, removed));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erreur lors de la suppression'),
              backgroundColor: const Color(0xFF1A1A1A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Action supprimée'),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Map<String, dynamic> _getConfig(Map<String, dynamic> action) {
    switch (action['action_type']) {
      case 'onboarding_started':
        return {
          'icon': Icons.person_add_rounded,
          'color': _lime,
          'label': 'Onboarding démarré',
          'badge': 'NOUVEAU',
        };
      case 'onboarding_completed':
        return {
          'icon': Icons.check_circle_rounded,
          'color': const Color(0xFF10B981),
          'label': 'Onboarding complété',
          'badge': 'ACTIF',
        };
      case 'leave_approved':
        return {
          'icon': Icons.event_available_rounded,
          'color': const Color(0xFF10B981),
          'label': 'Congé approuvé',
          'badge': 'APPROUVÉ',
        };
      case 'leave_refused':
        return {
          'icon': Icons.event_busy_rounded,
          'color': const Color(0xFFEF4444),
          'label': 'Congé refusé',
          'badge': 'REFUSÉ',
        };
      case 'offboarding_started':
        return {
          'icon': Icons.logout_rounded,
          'color': const Color(0xFFF59E0B),
          'label': 'Offboarding démarré',
          'badge': 'DÉPART',
        };
      case 'offboarding_completed':
        return {
          'icon': Icons.exit_to_app_rounded,
          'color': const Color(0xFFEF4444),
          'label': 'Offboarding complété',
          'badge': 'INACTIF',
        };
      case 'promotion':
        return {
          'icon': Icons.trending_up_rounded,
          'color': _purple,
          'label': 'Promotion',
          'badge': 'PROMU',
        };
      case 'absence_alert':
        return {
          'icon': Icons.warning_amber_rounded,
          'color': const Color(0xFFF59E0B),
          'label': 'Alerte absences',
          'badge': 'ALERTE',
        };
      default:
        return {
          'icon': Icons.auto_awesome_rounded,
          'color': _purple,
          'label': 'Action Hera',
          'badge': 'INFO',
        };
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
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC);
    final headerColor = isDark ? const Color(0xFF141414) : Colors.white;
    final cardColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF888888)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: headerColor,
                border: Border(
                  bottom: BorderSide(color: _lime.withOpacity(0.12)),
                ),
              ),
              child: Row(
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Icône Hera + titre
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _lime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: _lime,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique complet',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Toutes les actions de Hera',
                          style: TextStyle(color: mutedColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Badge compteur
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _lime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _lime.withOpacity(0.25)),
                    ),
                    child: Text(
                      '${_actions.length}',
                      style: const TextStyle(
                        color: _lime,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste ───────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: _lime))
                  : _actions.isEmpty
                  ? _buildEmpty(isDark, textColor, mutedColor)
                  : RefreshIndicator(
                      onRefresh: () => _loadActions(refresh: true),
                      color: _lime,
                      backgroundColor: headerColor,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll.metrics.pixels >=
                                  scroll.metrics.maxScrollExtent - 200 &&
                              _hasMore &&
                              !_loadingMore) {
                            _page++;
                            _loadActions();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _actions.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Loader pagination
                            if (index == _actions.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: _lime,
                                  ),
                                ),
                              );
                            }

                            final action = _actions[index];
                            final config = _getConfig(action);
                            final accent = config['color'] as Color;
                            final employeeName =
                                action['employee_name'] ?? 'Employé';
                            final createdAt = action['created_at'] != null
                                ? DateTime.tryParse(
                                    action['created_at'].toString(),
                                  )
                                : null;
                            final actionId = _extractId(action['_id']);

                            return Dismissible(
                              key: Key('hist_${actionId}_$index'),
                              direction: DismissDirection.startToEnd,
                              onDismissed: (_) =>
                                  _deleteAction(index, actionId),
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.25),
                                  ),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supprimer',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: accent.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Icône
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        config['icon'] as IconData,
                                        color: accent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Texte
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            employeeName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            config['label'] as String,
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Badge + temps
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            config['badge'] as String,
                                            style: TextStyle(
                                              color: accent,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        if (createdAt != null) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            _timeAgo(createdAt),
                                            style: TextStyle(
                                              color: mutedColor,
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

  Widget _buildEmpty(bool isDark, Color textColor, Color mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.history_rounded, color: _lime, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            'Aucune action',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'L\'historique Hera apparaîtra ici',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
