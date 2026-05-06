import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_budget_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_reminder_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_add_expense_sheet.dart';
import 'package:e_team/presentation/widgets/kash/kash_overview_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_expenses_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_budgets_tab.dart';
import 'package:e_team/presentation/widgets/kash/kash_reminders_tab.dart';

class KashDashboardScreen extends StatefulWidget {
  const KashDashboardScreen({Key? key}) : super(key: key);

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

        final userProvider = Provider.of<UserProvider>(context, listen: false);
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
              _buildHeader(d, energyBalance),
              const SizedBox(height: 10),
              _buildPillTabBar(d),
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

  Widget _buildHeader(bool d, int energy) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KP.card(d),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: KP.border(d)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: KP.text(d),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          AnimatedBuilder(
            animation: _glowController,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KP.primary.withValues(
                      alpha: 0.25 + 0.2 * _glowController.value,
                    ),
                    blurRadius: 14 + 8 * _glowController.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.asset(
                'assets/images/kash.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  backgroundColor: KP.primary,
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kash Dashboard',
                  style: TextStyle(
                    color: KP.text(d),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KP.primary.withValues(
                            alpha: 0.6 + 0.4 * _pulseController.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'FINANCIAL MANAGEMENT',
                      style: TextStyle(
                        color: KP.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: d
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⚡ $energy',
              style: TextStyle(
                color: KP.text(d),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabBar(bool d) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: KP.card(d),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: KP.border(d)),
    ),
    child: Row(
      children: List.generate(_tabs.length, (i) {
        final sel = _selectedTab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? KP.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tabs[i].$1,
                    size: 17,
                    color: sel ? Colors.white : KP.textMuted(d),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _tabs[i].$2,
                    style: TextStyle(
                      color: sel ? Colors.white : KP.textMuted(d),
                      fontSize: 10,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(d),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KP.border(d)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: _getCategoryColor(category),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor,
                  style: TextStyle(
                    color: KP.text(d),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: KP.textMuted(d),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE dd MMM', 'fr_FR').format(date),
                      style: TextStyle(color: KP.textMuted(d), fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: KP.textMuted(d))),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(color: KP.textMuted(d), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              color: KP.danger,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message, IconData icon, bool d) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: KP.card(d),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: KP.border(d)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: KP.textSoft(d)),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: KP.textMuted(d), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'SaaS': KP.accent,
      'Marketing': Colors.purple,
      'Travel': Colors.orange,
      'Office': Colors.green,
      'Salaries': KP.danger,
      'Other': KP.textMuted(false),
    };
    return colors[category] ?? KP.primary;
  }
}
