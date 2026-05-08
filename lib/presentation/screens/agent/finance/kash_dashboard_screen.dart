import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_budget_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_reminder_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_expense_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_dashboard_widgets.dart';
import 'package:e_team/presentation/widgets/kash/kash_overview_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_expenses_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_budgets_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_reminders_tab.dart';

class KashDashboardScreen extends StatefulWidget {
  const KashDashboardScreen({super.key});

  @override
  State<KashDashboardScreen> createState() => _KashDashboardScreenState();
}

class _KashDashboardScreenState extends State<KashDashboardScreen>
    with TickerProviderStateMixin {
  // State variables
  List<dynamic> _expenses = [];
  List<dynamic> _budgets = [];
  List<dynamic> _reminders = [];
  double _totalSpent = 0.0;
  double _totalBudget = 0.0;
  int _pendingReminders = 0;
  bool _loadingExpenses = false;
  bool _loadingBudgets = false;
  bool _loadingReminders = false;
  int _selectedTab =
      0; // 0 = Overview, 1 = Expenses, 2 = Budgets, 3 = Reminders

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  static const _tabs = [
    (Icons.trending_up_rounded, 'Aperçu'),
    (Icons.receipt_long_rounded, 'Dépenses'),
    (Icons.account_balance_rounded, 'Budgets'),
    (Icons.notifications_rounded, 'Paiements'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {});

      await Future.wait([_loadExpenses(), _loadBudgets(), _loadReminders()]);

      _calculateMetrics();

      // Update energy balance on refresh
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshFromApi();
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _loadExpenses() async {
    setState(() => _loadingExpenses = true);
    try {
      final expenses = await KashService.getExpenses();
      setState(() {
        _expenses = expenses;
      });
    } catch (_) {
    } finally {
      setState(() => _loadingExpenses = false);
    }
  }

  Future<void> _loadBudgets() async {
    setState(() => _loadingBudgets = true);
    try {
      final budgets = await KashService.getBudget();
      setState(() {
        _budgets = budgets;
      });
    } catch (_) {
    } finally {
      setState(() => _loadingBudgets = false);
    }
  }

  Future<void> _loadReminders() async {
    setState(() => _loadingReminders = true);
    try {
      final reminders = await KashService.getReminders();
      setState(() {
        _reminders = reminders;
      });
    } catch (_) {
    } finally {
      setState(() => _loadingReminders = false);
    }
  }

  dynamic _readValue(dynamic item, String key) {
    if (item is Map) return item[key];

    try {
      switch (key) {
        case 'vendor':
          return item.vendor;
        case 'amount':
          return item.amount;
        case 'currency':
          return item.currency;
        case 'category':
          return item.category;
        case 'date':
          return item.date;
        case 'limit':
          return item.limit;
        case 'spent':
          return item.spent;
        case 'status':
          return item.status;
        case 'title':
          return item.title;
        case 'dueDate':
          return item.dueDate;
        case 'id':
          return item.id;
        case '_id':
          return item.id;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  DateTime _safeDate(dynamic value) {
    if (value is DateTime) return value;
    if (value != null) {
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void _calculateMetrics() {
    setState(() {
      _totalSpent = 0.0;

      for (final expense in _expenses) {
        final amount =
            (_readValue(expense, 'amount') as num?)?.toDouble() ?? 0.0;
        _totalSpent += amount;
      }

      _totalBudget = 0.0;

      for (final budget in _budgets) {
        final limit = (_readValue(budget, 'limit') as num?)?.toDouble() ?? 0.0;
        _totalBudget += limit;
      }

      _pendingReminders = _reminders
          .where((r) => _readValue(r, 'status') == 'pending')
          .length;
    });
  }

  /// Get combined list of categories: budget categories first, then standard categories
  /// Removes duplicates automatically
  List<String> _getCombinedCategories() {
    final categories = <String>{};

    for (final budget in _budgets) {
      final category = _readValue(budget, 'category')?.toString();
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }

    categories.addAll([
      'SaaS',
      'Marketing',
      'Travel',
      'Office',
      'Salaries',
      'Other',
    ]);

    return categories.toList();
  }

  Future<void> _markReminderPaid(String reminderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await KashService.markReminderPaid(reminderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment marked as done — expense created'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadDashboardData();

        await userProvider.refreshFromApi();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddBudgetSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showKashAddBudgetSheet(
      context: context,
      isDark: isDark,
      onBudgetCreated: () async {
        await _loadDashboardData();
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshFromApi();
      },
    );
  }

  void _showAddReminderSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showKashAddReminderSheet(
      context: context,
      isDark: isDark,
      onReminderCreated: () async {
        await _loadDashboardData();
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshFromApi();
      },
    );
  }

  void _showAddExpenseSheet() {
    final d = Theme.of(context).brightness == Brightness.dark;
    showKashAddExpenseSheet(
      context: context,
      isDark: d,
      categories: _getCombinedCategories(),
      onExpenseCreated: () async {
        _loadDashboardData();
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshFromApi();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final energyBalance = userProvider.user?.energyBalance ?? 0;
    final d = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: KP.bg(d),
      body: FadeTransition(
        opacity: _fadeController,
        child: SafeArea(
          child: Column(
            children: [
              KashDashboardHeader(
                isDark: d,
                energy: energyBalance,
                pulseController: _pulseController,
                glowController: _glowController,
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              KashPillTabBar(
                isDark: d,
                tabs: _tabs,
                selectedTab: _selectedTab,
                onTabSelected: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  color: KP.primary,
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildOverviewTab(d),
                      _buildExpensesTab(d),
                      _buildBudgetsTab(d),
                      _buildRemindersTab(d),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool d) {
    return KashOverviewTab(
      isDark: d,
      loadingExpenses: _loadingExpenses,
      totalSpent: _totalSpent,
      totalBudget: _totalBudget,
      pendingReminders: _pendingReminders,
      expenses: _expenses,
      onAddExpense: _showAddExpenseSheet,
      buildExpenseCard: _buildExpenseCard,
      buildEmptyState: _emptyState,
    );
  }

  Widget _buildExpensesTab(bool d) {
    return KashExpensesTab(
      isDark: d,
      loadingExpenses: _loadingExpenses,
      expenses: _expenses,
      onAddExpense: _showAddExpenseSheet,
      buildExpenseCard: _buildExpenseCard,
      buildEmptyState: _emptyState,
    );
  }

  Widget _buildBudgetsTab(bool d) {
    return KashBudgetsTab(
      isDark: d,
      loadingBudgets: _loadingBudgets,
      budgets: _budgets,
      onAddBudget: _showAddBudgetSheet,
      buildEmptyState: _emptyState,
      readValue: _readValue,
    );
  }

  Widget _buildRemindersTab(bool d) {
    return KashRemindersTab(
      isDark: d,
      loadingReminders: _loadingReminders,
      reminders: _reminders,
      onAddReminder: _showAddReminderSheet,
      buildEmptyState: _emptyState,
      readValue: _readValue,
      safeDate: _safeDate,
      onMarkReminderPaid: _markReminderPaid,
    );
  }

  Widget _buildExpenseCard(dynamic expense, bool d) {
    final vendor = (_readValue(expense, 'vendor') ?? 'Unknown').toString();
    final amount = (_readValue(expense, 'amount') as num?)?.toDouble() ?? 0.0;
    final currency = (_readValue(expense, 'currency') ?? 'TND').toString();
    final category = (_readValue(expense, 'category') ?? 'Other').toString();
    final date = _safeDate(_readValue(expense, 'date'));

    return KashExpenseCard(
      isDark: d,
      vendor: vendor,
      amount: amount,
      currency: currency,
      category: category,
      date: date,
    );
  }

  Widget _emptyState(String message, IconData icon, bool d) {
    return KashEmptyState(message: message, icon: icon, isDark: d);
  }
}
