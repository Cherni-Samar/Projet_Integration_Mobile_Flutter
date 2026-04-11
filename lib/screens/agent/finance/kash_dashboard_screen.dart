import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/user_provider.dart';
import '../../../services/kash_service.dart';

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
  double _expensesThisMonth = 0.0;
  bool _loadingExpenses = false;
  bool _loadingBudgets = false;
  bool _loadingReminders = false;
  String _errorMessage = '';
  int _selectedTab = 0; // 0 = Overview, 1 = Expenses, 2 = Budgets, 3 = Reminders
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      await Future.wait([
        _loadExpenses(),
        _loadBudgets(),
        _loadReminders(),
      ]);

      _calculateMetrics();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading dashboard: $e';
      });
    }
  }

  Future<void> _loadExpenses() async {
    setState(() => _loadingExpenses = true);
    try {
      final expenses = await KashService.getExpenses();
      setState(() {
        _expenses = expenses;
      });
    } catch (e) {
      print('Error loading expenses: $e');
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
    } catch (e) {
      print('Error loading budgets: $e');
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
    } catch (e) {
      print('Error loading reminders: $e');
    } finally {
      setState(() => _loadingReminders = false);
    }
  }

  void _calculateMetrics() {
    setState(() {
      // Total spent from expenses
      _totalSpent = 0.0;
      for (var expense in _expenses) {
        final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
        _totalSpent += amount;
      }

      // Total budget from budgets
      _totalBudget = 0.0;
      for (var budget in _budgets) {
        final amount = (budget['amount'] as num?)?.toDouble() ?? 0.0;
        _totalBudget += amount;
      }

      // Pending reminders count
      _pendingReminders = _reminders
          .where((r) => r['status'] == 'pending')
          .toList()
          .length;

      // Expenses this month
      _expensesThisMonth = 0.0;
      final now = DateTime.now();
      for (var expense in _expenses) {
        final date = expense['date'] != null
            ? DateTime.parse(expense['date'].toString())
            : null;
        if (date != null &&
            date.year == now.year &&
            date.month == now.month) {
          final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
          _expensesThisMonth += amount;
        }
      }
    });
  }

  Future<void> _markReminderPaid(String reminderId) async {
    try {
      final updatedReminder =
          await KashService.markReminderPaid(reminderId);
      setState(() {
        // Update reminder status locally
        final index = _reminders.indexWhere(
          (r) => r['_id'] == reminderId || r['id'] == reminderId,
        );
        if (index >= 0) {
          _reminders[index]['status'] = 'paid';
        }

        // Add new expense from reminder data
        final newExpense = {
          'vendor': updatedReminder['title'] ?? 'Payment',
          'amount': updatedReminder['amount'],
          'currency': updatedReminder['currency'] ?? 'TND',
          'category': 'Other',
          'date': DateTime.now().toIso8601String(),
          'description': updatedReminder['notes'] ?? '',
        };
        _expenses.insert(0, newExpense);

        // Recalculate metrics
        _calculateMetrics();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment marked as done — expense created'),
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
                labelText: 'Project name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                        const SnackBar(
                          content: Text('Please fill all fields'),
                        ),
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
    String selectedCurrency = 'TND';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

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
                'Add Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['TND', 'USD', 'EUR'].map((cur) {
                  return DropdownMenuItem(
                    value: cur,
                    child: Text(cur),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setModalState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                          amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      try {
                        await KashService.createReminder({
                          'title': titleController.text,
                          'amount': double.parse(amountController.text),
                          'currency': selectedCurrency,
                          'dueDate': selectedDate.toIso8601String(),
                          'notes': notesController.text,
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
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExpenseSheet() {
    final vendorController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCurrency = 'TND';
    String selectedCategory = 'Other';
    DateTime selectedDate = DateTime.now();

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
                'Add Expense',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vendorController,
                decoration: InputDecoration(
                  labelText: 'Vendor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['TND', 'USD', 'EUR'].map((cur) {
                  return DropdownMenuItem(
                    value: cur,
                    child: Text(cur),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['SaaS', 'Marketing', 'Travel', 'Office', 'Salaries', 'Other']
                    .map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setModalState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                      if (vendorController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      try {
                        await KashService.addExpense({
                          'vendor': vendorController.text,
                          'amount': double.parse(amountController.text),
                          'currency': selectedCurrency,
                          'category': selectedCategory,
                          'date': selectedDate.toIso8601String(),
                          'description': descriptionController.text,
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          _loadExpenses();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Expense added'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final energyBalance = userProvider.user?.energyBalance ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Professional Header
          _buildProfileHeader(energyBalance, isDark),
          
          // Tab Navigation
          _buildTabNavigation(isDark),
          
          // Content
          Expanded(
            child: _buildTabContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(int energyBalance, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4),
            const Color(0xFF0097A7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 10, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kash Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyan.shade300, Colors.cyan.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Kash Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kash Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Financial Management Agent',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⚡ $energyBalance Energy',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              top: false,
              bottom: false,
              left: false,
              right: false,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black26,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('📊 Overview', 0, isDark),
          _buildTabButton('💰 Expenses', 1, isDark),
          _buildTabButton('💵 Budgets', 2, isDark),
          _buildTabButton('🔔 Reminders', 3, isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF00BCD4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(isDark);
      case 1:
        return _buildExpensesTab(isDark);
      case 2:
        return _buildBudgetsTab(isDark);
      case 3:
        return _buildRemindersTab(isDark);
      default:
        return _buildOverviewTab(isDark);
    }
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row 1
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Spent',
                  '${_totalSpent.toStringAsFixed(2)} DT',
                  Icons.trending_down,
                  Colors.red,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Budget',
                  '${_totalBudget.toStringAsFixed(2)} DT',
                  Icons.account_balance,
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Stats Cards Row 2
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Budget Remaining',
                  '${(_totalBudget - _totalSpent).toStringAsFixed(2)} DT',
                  Icons.savings,
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  '${_expensesThisMonth.toStringAsFixed(2)} DT',
                  Icons.calendar_month,
                  Colors.purple,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Pending Reminders
          _buildStatCard(
            'Pending Payments',
            _pendingReminders.toString(),
            Icons.notifications,
            Colors.orange,
            isDark,
          ),
          
          const SizedBox(height: 32),
          
          // Recent Expenses Section
          _buildSectionHeader('Recent Expenses', isDark, _showAddExpenseSheet),
          const SizedBox(height: 12),
          if (_loadingExpenses)
            const Center(child: CircularProgressIndicator())
          else if (_expenses.isEmpty)
            _buildEmptyState('No expenses yet', Icons.inbox, isDark)
          else
            ..._expenses.take(5).map((expense) => _buildExpenseCard(expense, isDark)),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: _showAddExpenseSheet,
                heroTag: 'add_expense',
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingExpenses)
            const Center(child: CircularProgressIndicator())
          else if (_expenses.isEmpty)
            _buildEmptyState('No expenses yet', Icons.inbox, isDark)
          else
            ..._expenses.map((expense) => _buildExpenseCard(expense, isDark)),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budgets by Project',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: _showAddBudgetSheet,
                heroTag: 'add_budget',
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingBudgets)
            const Center(child: CircularProgressIndicator())
          else if (_budgets.isEmpty)
            _buildEmptyState('No budgets yet', Icons.trending_up, isDark)
          else
            ..._budgets.map((budget) => _buildBudgetCard(budget, isDark)),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: _showAddReminderSheet,
                heroTag: 'add_reminder',
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingReminders)
            const Center(child: CircularProgressIndicator())
          else if (_reminders.isEmpty)
            _buildEmptyState('No reminders yet', Icons.notifications_off, isDark)
          else
            ..._reminders.map((reminder) => _buildReminderCard(reminder, isDark)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(dynamic expense, bool isDark) {
    final vendor = expense['vendor'] ?? 'Unknown';
    final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
    final currency = expense['currency'] ?? 'TND';
    final category = expense['category'] ?? 'Other';
    final date = expense['date'] != null
        ? DateTime.parse(expense['date'].toString())
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(date)} • $category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amount $currency',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(dynamic budget, bool isDark) {
    final project = budget['project'] ?? 'Unknown';
    final amount = (budget['amount'] as num?)?.toDouble() ?? 0.0;
    final spent = (budget['spent'] as num?)?.toDouble() ?? 0.0;
    final percentage = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
    final color = percentage > 0.8
        ? Colors.red
        : percentage > 0.5
            ? Colors.orange
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                project,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${spent.toStringAsFixed(2)} / ${amount.toStringAsFixed(2)} DT',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(dynamic reminder, bool isDark) {
    final title = reminder['title'] ?? 'Unnamed';
    final status = reminder['status'] ?? 'pending';
    final amount = (reminder['amount'] as num?)?.toDouble() ?? 0.0;
    final dueDate = reminder['dueDate'] != null
        ? DateTime.parse(reminder['dueDate'].toString())
        : DateTime.now();
    final isOverdue = status == 'pending' && dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${amount.toStringAsFixed(2)} DT • ${DateFormat('MMM dd').format(dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.1)
                      : status == 'paid'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOverdue
                      ? 'OVERDUE'
                      : status == 'paid'
                          ? 'PAID'
                          : 'UPCOMING',
                  style: TextStyle(
                    color: isOverdue
                        ? Colors.red
                        : status == 'paid'
                            ? Colors.green
                            : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (status != 'paid') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markReminderPaid(reminder['_id'] ?? reminder['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mark Paid'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onPressed,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'SaaS': Colors.blue,
      'Marketing': Colors.purple,
      'Travel': Colors.orange,
      'Office': Colors.green,
      'Salaries': Colors.red,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}
