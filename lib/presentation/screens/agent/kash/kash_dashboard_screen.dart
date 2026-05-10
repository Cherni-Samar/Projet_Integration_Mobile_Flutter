import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';
import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_budget_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_reminder_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_expense_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_dashboard_cards.dart';
import 'package:e_team/presentation/widgets/kash/kash_dashboard_header.dart';
import 'package:e_team/presentation/widgets/kash/kash_dashboard_tabs.dart';
import 'package:e_team/presentation/widgets/kash/kash_overview_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_expenses_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_budgets_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_reminders_tab.dart';
import 'package:e_team/presentation/utils/kash_dashboard_data.dart';

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

  void _calculateMetrics() {
    final metrics = calculateKashDashboardMetrics(
      expenses: _expenses,
      budgets: _budgets,
      reminders: _reminders,
    );
    setState(() {
      _totalSpent = metrics.totalSpent;
      _totalBudget = metrics.totalBudget;
      _pendingReminders = metrics.pendingReminders;
    });
  }

  Future<void> _markReminderPaid(String reminderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await KashService.markReminderPaid(reminderId);

      if (mounted) {
        AppSnackBar.success(
          context,
          'Payment marked as done — expense created',
        );

        await _loadDashboardData();

        await userProvider.refreshFromApi();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error: $e');
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
      categories: kashCombinedCategories(_budgets),
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
      readValue: kashReadValue,
    );
  }

  Widget _buildRemindersTab(bool d) {
    return KashRemindersTab(
      isDark: d,
      loadingReminders: _loadingReminders,
      reminders: _reminders,
      onAddReminder: _showAddReminderSheet,
      buildEmptyState: _emptyState,
      readValue: kashReadValue,
      safeDate: kashSafeDate,
      onMarkReminderPaid: _markReminderPaid,
    );
  }

  Widget _buildExpenseCard(dynamic expense, bool d) {
    final vendor = (kashReadValue(expense, 'vendor') ?? 'Unknown').toString();
    final amount =
        (kashReadValue(expense, 'amount') as num?)?.toDouble() ?? 0.0;
    final currency = (kashReadValue(expense, 'currency') ?? 'TND').toString();
    final category = (kashReadValue(expense, 'category') ?? 'Other').toString();
    final date = kashSafeDate(kashReadValue(expense, 'date'));

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
