import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../providers/user_provider.dart';
import '../../../services/kash_service.dart';

class KashDashboardScreen extends StatefulWidget {
  const KashDashboardScreen({super.key});

  @override
  State<KashDashboardScreen> createState() => _KashDashboardScreenState();
}

class _KashDashboardScreenState extends State<KashDashboardScreen> with TickerProviderStateMixin {
  // Data
  List<dynamic> _expenses = [];
  List<dynamic> _budgets = [];
  List<dynamic> _reminders = [];

  // Loading states
  bool _loadingExpenses = true;
  bool _loadingBudgets = true;
  bool _loadingReminders = true;
  bool _isLoading = false;

  // Error states
  String? _errorMessage;

  // Calculated values
  double _totalSpent = 0.0;
  double _totalBudget = 0.0;
  int _pendingReminders = 0;
  int _expensesThisMonth = 0;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this as TickerProvider,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _errorMessage = null);
    await Future.wait([
      _loadExpenses(),
      _loadBudgets(),
      _loadReminders(),
    ]);
    _calculateMetrics();
  }

  Future<void> _loadExpenses() async {
    setState(() => _loadingExpenses = true);
    try {
      final expenses = await KashService.getExpenses();
      setState(() {
        _expenses = expenses;
        _loadingExpenses = false;
      });
    } catch (e) {
      setState(() {
        _loadingExpenses = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadBudgets() async {
    setState(() => _loadingBudgets = true);
    try {
      final budgets = await KashService.getBudget();
      setState(() {
        _budgets = budgets;
        _loadingBudgets = false;
      });
    } catch (e) {
      setState(() {
        _loadingBudgets = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadReminders() async {
    setState(() => _loadingReminders = true);
    try {
      final reminders = await KashService.getReminders();
      setState(() {
        _reminders = reminders;
        _loadingReminders = false;
      });
    } catch (e) {
      setState(() {
        _loadingReminders = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _calculateMetrics() {
    // Total spent
    _totalSpent = 0.0;
    for (var expense in _expenses) {
      _totalSpent += (expense['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // Total budget
    _totalBudget = 0.0;
    for (var budget in _budgets) {
      _totalBudget += (budget['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // Pending reminders
    _pendingReminders = _reminders.where((r) => r['status'] == 'pending').length;

    // Expenses this month
    final now = DateTime.now();
    _expensesThisMonth = _expenses.where((e) {
      try {
        final date = DateTime.parse(e['date'] ?? '');
        return date.month == now.month && date.year == now.year;
      } catch (_) {
        return false;
      }
    }).length;
  }

  void _showAddBudgetSheet() {
    final projectController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: projectController,
              decoration: InputDecoration(
                hintText: 'Project name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    if (projectController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    try {
                      await KashService.setBudget(
                        projectController.text,
                        double.parse(amountController.text),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        _loadBudgets();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Budget added'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setModalState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'Select due date',
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill title, amount, and date'),
                          ),
                        );
                        return;
                      }

                      try {
                        await KashService.createReminder({
                          'title': titleController.text,
                          'amount': double.parse(amountController.text),
                          'dueDate': selectedDate!.toIso8601String(),
                          'notes': notesController.text,
                          'currency': 'TND',
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          _loadReminders();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Reminder created'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markReminderPaid(String reminderId) async {
    try {
      await KashService.markReminderPaid(reminderId);
      _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reminder marked as paid'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getReminderStatus(dynamic reminder) {
    try {
      final dueDate = DateTime.parse(reminder['dueDate'] ?? '');
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;

      if (reminder['status'] == 'paid') return 'paid';
      if (difference < 0) return 'overdue';
      if (difference <= 3) return 'upcoming';
      return 'normal';
    } catch (_) {
      return 'normal';
    }
  }

  Color _getReminderStatusColor(String status) {
    switch (status) {
      case 'overdue':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'saas':
        return '💻';
      case 'marketing':
        return '📢';
      case 'travel':
        return '✈️';
      case 'office':
        return '🏢';
      case 'salaries':
        return '👥';
      default:
        return '💳';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final energyBalance = userProvider.energyBalance;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wallet, size: 24),
            const SizedBox(width: 8),
            const Text('Kash'),
          ],
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, size: 16, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      '$energyBalance',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metrics Row
                        _buildMetricsRow(),
                        const SizedBox(height: 24),

                        // Budget Section
                        _buildBudgetSection(),
                        const SizedBox(height: 24),

                        // Expense Categories
                        _buildCategorySection(),
                        const SizedBox(height: 24),

                        // Reminders Section
                        _buildRemindersSection(),
                        const SizedBox(height: 24),

                        // Recent Expenses
                        _buildRecentExpensesSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MetricCard(
            label: 'Total Spent',
            value: '${_totalSpent.toStringAsFixed(2)} DT',
            icon: Icons.trending_down,
            color: Colors.red,
            isLoading: _loadingExpenses,
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: 'Budget Remaining',
            value: '${(_totalBudget - _totalSpent).toStringAsFixed(2)} DT',
            icon: Icons.account_balance_wallet,
            color: Colors.green,
            isLoading: _loadingBudgets || _loadingExpenses,
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: 'Pending Payments',
            value: '$_pendingReminders',
            icon: Icons.payment,
            color: Colors.orange,
            isLoading: _loadingReminders,
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: 'This Month',
            value: '$_expensesThisMonth',
            icon: Icons.calendar_month,
            color: Colors.blue,
            isLoading: _loadingExpenses,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget by Project',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddBudgetSheet,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingBudgets)
          const Center(child: CircularProgressIndicator())
        else if (_budgets.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No budgets yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          Column(
            children: [
              ..._budgets.map((budget) {
                final amount = (budget['amount'] as num?)?.toDouble() ?? 0.0;
                final spent = (budget['spent'] as num?)?.toDouble() ?? 0.0;
                final percentage = amount > 0 ? (spent / amount) : 0.0;
                final project = budget['project'] ?? 'Unknown';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(project,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                          Text('${spent.toStringAsFixed(2)} / ${amount.toStringAsFixed(2)} DT',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor:
                              Colors.grey.withOpacity(0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            percentage > 0.8
                                ? Colors.red
                                : percentage > 0.5
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildCategorySection() {
    if (_loadingExpenses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Group by category
    final categories = <String, int>{};
    for (var expense in _expenses) {
      final cat = expense['category'] ?? 'Other';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expenses by Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.entries
              .map((e) => Chip(
                    label: Text('${e.key} (${e.value})'),
                    avatar: Text(_getCategoryIcon(e.key)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Reminders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddReminderSheet,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingReminders)
          const Center(child: CircularProgressIndicator())
        else if (_reminders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No reminders yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          Column(
            children: [
              ..._reminders.map((reminder) {
                final status = _getReminderStatus(reminder);
                final statusColor = _getReminderStatusColor(status);
                final title = reminder['title'] ?? 'Reminder';
                final amount = reminder['amount'] ?? 0;
                final currency = reminder['currency'] ?? 'TND';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$amount $currency',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (status != 'paid')
                            TextButton(
                              onPressed: () {
                                _markReminderPaid(reminder['_id'] ?? '');
                              },
                              child: const Text('Mark Paid'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildRecentExpensesSection() {
    final recentExpenses = _expenses.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Expenses',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (_loadingExpenses)
          const Center(child: CircularProgressIndicator())
        else if (recentExpenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No expenses yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          Column(
            children: [
              ...recentExpenses.map((expense) {
                final category = expense['category'] ?? 'Other';
                final vendor = expense['vendor'] ?? 'Unknown';
                final amount = expense['amount'] ?? 0;
                final date = expense['date'] ?? '';
                final icon = _getCategoryIcon(category);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendor,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$amount DT',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            SizedBox(
              height: 20,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
