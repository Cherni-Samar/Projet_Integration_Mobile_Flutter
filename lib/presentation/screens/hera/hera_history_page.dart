import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/presentation/widgets/hera/history/hera_history_config.dart';
import 'package:e_team/presentation/widgets/hera/history/hera_history_empty_state.dart';
import 'package:e_team/presentation/widgets/hera/history/hera_history_header.dart';
import 'package:e_team/presentation/widgets/hera/history/hera_history_item.dart';
import 'package:e_team/presentation/widgets/hera/history/hera_history_loading.dart';
import 'package:flutter/material.dart';

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

  final Set<String> _deletedIds = {};

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

        final filtered = newActions.where((action) {
          final id = _extractId(action['_id']);
          return id == null || !_deletedIds.contains(id);
        }).toList();

        setState(() {
          _actions.addAll(filtered);
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
    } catch (_) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _deleteAction(int index, String? actionId) async {
    if (index >= _actions.length) return;
    final removed = _actions[index];

    if (actionId != null && actionId.isNotEmpty) {
      _deletedIds.add(actionId);
    }

    setState(() => _actions.removeAt(index));

    if (actionId != null && actionId.isNotEmpty) {
      try {
        await HeraService.deleteAction(actionId);
      } catch (_) {
        if (mounted) {
          _deletedIds.remove(actionId);
          setState(() => _actions.insert(index, removed));
          _showSnackBar('Erreur lors de la suppression');
          return;
        }
      }
    }

    if (mounted) {
      _showSnackBar('Action supprimée');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC);
    final headerColor = isDark ? const Color(0xFF141414) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            HeraHistoryHeader(
              isDark: isDark,
              actionCount: _actions.length,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: HeraHistoryTheme.lime,
                      ),
                    )
                  : _actions.isEmpty
                  ? HeraHistoryEmptyState(isDark: isDark)
                  : RefreshIndicator(
                      onRefresh: () => _loadActions(refresh: true),
                      color: HeraHistoryTheme.lime,
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
                            if (index == _actions.length) {
                              return const HeraHistoryLoadingMoreIndicator();
                            }

                            final action = _actions[index];
                            final actionId = _extractId(action['_id']);

                            return Dismissible(
                              key: Key('hist_${actionId}_$index'),
                              direction: DismissDirection.startToEnd,
                              onDismissed: (_) =>
                                  _deleteAction(index, actionId),
                              background: const HeraHistoryDismissBackground(),
                              child: HeraHistoryItem(
                                action: action,
                                isDark: isDark,
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
}
