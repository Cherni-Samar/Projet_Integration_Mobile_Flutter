import 'package:e_team/data/services/activity_service.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/activity/activity_cards.dart';
import 'package:e_team/presentation/widgets/activity/activity_filters.dart';
import 'package:e_team/presentation/widgets/activity/activity_overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  ActivityDashboard? _dashboard;
  List<ActivityItem> _activities = [];
  ActivityPagination? _pagination;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _selectedAgent = 'all';
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  final List<String> _agentFilters = [
    'all',
    'echo',
    'hera',
    'dexo',
    'kash',
    'timo',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreActivities();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final dashboard = await ActivityService.getDashboard();
      final feedResponse = await ActivityService.getMobileFeed(
        page: 1,
        agentFilter: _selectedAgent,
      );

      setState(() {
        _dashboard = dashboard;
        _activities = feedResponse.activities;
        _pagination = feedResponse.pagination;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load activity data: $e');
    }
  }

  Future<void> _loadMoreActivities() async {
    if (_isLoadingMore || _pagination?.hasNext != true) return;

    setState(() => _isLoadingMore = true);

    try {
      final feedResponse = await ActivityService.getMobileFeed(
        page: _currentPage + 1,
        agentFilter: _selectedAgent,
      );

      setState(() {
        _activities.addAll(feedResponse.activities);
        _pagination = feedResponse.pagination;
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      _showError('Failed to load more activities: $e');
    }
  }

  Future<void> _onAgentFilterChanged(String agent) async {
    if (agent == _selectedAgent) return;

    setState(() {
      _selectedAgent = agent;
      _isLoading = true;
      _activities.clear();
    });

    try {
      final feedResponse = await ActivityService.getMobileFeed(
        page: 1,
        agentFilter: _selectedAgent,
      );

      setState(() {
        _activities = feedResponse.activities;
        _pagination = feedResponse.pagination;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to filter activities: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Activity Logs',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: isDark ? 0 : 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (_dashboard != null)
                    SliverToBoxAdapter(
                      child: ActivityDashboardOverview(
                        dashboard: _dashboard!,
                        isDark: isDark,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ActivityAgentFilter(
                      agentFilters: _agentFilters,
                      selectedAgent: _selectedAgent,
                      isDark: isDark,
                      onChanged: _onAgentFilterChanged,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _activities.length) {
                          return ActivityCard(
                            activity: _activities[index],
                            isDark: isDark,
                          );
                        } else if (_isLoadingMore) {
                          return const ActivityLoadingMoreIndicator();
                        }
                        return null;
                      },
                      childCount: _activities.length + (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
