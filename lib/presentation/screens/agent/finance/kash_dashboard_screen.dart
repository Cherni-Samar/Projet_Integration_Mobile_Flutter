import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/user_provider.dart';
import '/data/services/kash_service.dart';

// ─────────────────────────────────────────────────────────────
//  PALETTE KASH - Teal/Green scheme matching Timo's design
// ─────────────────────────────────────────────────────────────
class KP {
  static const primary   = Color(0xFF008B8B);  // Deep teal
  static const primaryD  = Color(0xFF006666);  // Darker teal
  static const accent    = Color(0xFF20B2AA); // Light sea green
  static const success   = Color(0xFF10B981);
  static const danger    = Color(0xFFEF4444);
  static const warning   = Color(0xFFFB923C);

  static Color bg(bool d)        => d ? const Color(0xFF0A0A0A) : const Color(0xFFF5F3F0);
  static Color card(bool d)      => d ? const Color(0xFF141414) : Colors.white;
  static Color cardSoft(bool d)  => d ? const Color(0xFF1C1C1C) : const Color(0xFFEEEBE7);
  static Color border(bool d)    => d ? const Color(0xFF252525) : const Color(0xFFE0DBD4);
  static Color text(bool d)      => d ? Colors.white            : const Color(0xFF1A1008);
  static Color textMuted(bool d) => d ? const Color(0xFF777777) : const Color(0xFF8B7D6E);
  static Color textSoft(bool d)  => d ? const Color(0xFF444444) : const Color(0xFFB5A99A);
}

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
  int _selectedTab = 0; // 0 = Overview, 1 = Expenses, 2 = Budgets, 3 = Reminders

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  static const _tabs = [
    (Icons.trending_up_rounded,      'Aperçu'),
    (Icons.receipt_long_rounded,     'Dépenses'),
    (Icons.account_balance_rounded,  'Budgets'),
    (Icons.notifications_rounded,    'Paiements'),
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

      await Future.wait([
        _loadExpenses(),
        _loadBudgets(),
        _loadReminders(),
      ]);

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
        final amount = (_readValue(expense, 'amount') as num?)?.toDouble() ?? 0.0;
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

    categories.addAll(['SaaS', 'Marketing', 'Travel', 'Office', 'Salaries', 'Other']);

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
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _showAddBudgetSheet() {
    final amountController = TextEditingController();
    String selectedCurrency = 'TND';
    String selectedCategory = 'Marketing';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KP.card(Theme.of(context).brightness == Brightness.dark),
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
                'Ajouter un Budget',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Text(
                'Catégorie',
                style: TextStyle(
                  color: KP.text(Theme.of(context).brightness == Brightness.dark),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Sélectionner une catégorie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: KP.cardSoft(Theme.of(context).brightness == Brightness.dark),
                ),
                items: const [
                  DropdownMenuItem(value: 'SaaS', child: Text('SaaS')),
                  DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                  DropdownMenuItem(value: 'Travel', child: Text('Travel')),
                  DropdownMenuItem(value: 'Office', child: Text('Office')),
                  DropdownMenuItem(value: 'Salaries', child: Text('Salaries')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => selectedCategory = value);
                  }
                },
                dropdownColor: KP.card(Theme.of(context).brightness == Brightness.dark),
              ),
              const SizedBox(height: 14),

              // Limit Amount TextField
              Text(
                'Montant Limite',
                style: TextStyle(
                  color: KP.text(Theme.of(context).brightness == Brightness.dark),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                style: TextStyle(
                  color: KP.text(Theme.of(context).brightness == Brightness.dark),
                ),
                decoration: InputDecoration(
                  labelText: 'Ex: 5000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: KP.cardSoft(Theme.of(context).brightness == Brightness.dark),
                ),
              ),
              const SizedBox(height: 14),

              // Currency Dropdown
              Text(
                'Devise',
                style: TextStyle(
                  color: KP.text(Theme.of(context).brightness == Brightness.dark),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Sélectionner une devise',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: KP.cardSoft(Theme.of(context).brightness == Brightness.dark),
                ),
                items: const [
                  DropdownMenuItem(value: 'TND', child: Text('TND (Tunisien)')),
                  DropdownMenuItem(value: 'USD', child: Text('USD (Américain)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (Européen)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() => selectedCurrency = value);
                  }
                },
                dropdownColor: KP.card(Theme.of(context).brightness == Brightness.dark),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: KP.textMuted(Theme.of(context).brightness == Brightness.dark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: KP.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // Capture parent context references before async operations
                      final messenger = ScaffoldMessenger.of(this.context);
                      final navigator = Navigator.of(context);

                      if (selectedCategory.isEmpty || amountController.text.isEmpty) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Veuillez remplir tous les champs'),
                            backgroundColor: KP.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      try {
                        final amount = double.parse(amountController.text);
                        if (amount <= 0) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text('Le montant doit être supérieur à 0'),
                              backgroundColor: KP.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // Call the API to create budget
                        await KashService.createBudget(
                          category: selectedCategory,
                          limit: amount,
                          currency: selectedCurrency,
                        );

                        // Check if widget is still mounted before proceeding
                        if (!mounted) return;

                        navigator.pop();

                        // Refresh the dashboard and user data
                        await _loadDashboardData();

                        final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                        await userProvider.refreshFromApi();

                        // Show success message using captured messenger
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('✅ Budget créé avec succès'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } on FormatException {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Montant invalide'),
                            backgroundColor: KP.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('❌ Erreur: $e'),
                            backgroundColor: KP.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Créer le Budget',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                      // Capture parent context references before async operations
                      final messenger = ScaffoldMessenger.of(this.context);
                      final navigator = Navigator.of(context);

                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        messenger.showSnackBar(
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
                        
                        if (!mounted) return;
                        
                        navigator.pop();
                        _loadDashboardData();
                        
                        // Update energy balance after reminder is created
                        final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                        await userProvider.refreshFromApi();
                        
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✅ Reminder created'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
    final combinedCategories = _getCombinedCategories();
    String selectedCategory = combinedCategories.isNotEmpty ? combinedCategories.first : 'Other';
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
                  labelText: 'Category / Budget Project',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: combinedCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
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
                      // Capture parent context references before async operations
                      final messenger = ScaffoldMessenger.of(this.context);
                      final navigator = Navigator.of(context);

                      if (vendorController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        messenger.showSnackBar(
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
                        
                        if (!mounted) return;
                        
                        navigator.pop();
                        _loadDashboardData();
                        
                        // Update energy balance after expense is added
                        final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                        await userProvider.refreshFromApi();
                        
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✅ Expense added'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
                color: d ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: KP.text(d), size: 16),
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
                    color: KP.primary.withOpacity(0.25 + 0.2 * _glowController.value),
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
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white),
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
                          color: KP.primary.withOpacity(0.6 + 0.4 * _pulseController.value),
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
              color: d ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
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
                  Icon(_tabs[i].$1, size: 17, color: sel ? Colors.white : KP.textMuted(d)),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        _buildStatsPulse(d),
        const SizedBox(height: 16),
        _buildRecentExpenses(d),
      ],
    );
  }

  Widget _buildStatsPulse(bool d) {
    final pct = _totalBudget > 0 ? (_totalSpent / _totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KP.card(d),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: KP.border(d)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  _totalSpent.toStringAsFixed(2),
                  'DÉPENSÉ',
                  KP.danger,
                  Icons.trending_down_rounded,
                  d,
                ),
              ),
              Container(width: 1, height: 50, color: KP.border(d)),
              Expanded(
                child: _statItem(
                  _totalBudget.toStringAsFixed(2),
                  'BUDGET',
                  KP.primary,
                  Icons.account_balance_rounded,
                  d,
                ),
              ),
              Container(width: 1, height: 50, color: KP.border(d)),
              Expanded(
                child: _statItem(
                  '${_pendingReminders}',
                  'PAIEMENTS',
                  KP.warning,
                  Icons.notifications_rounded,
                  d,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Utilisation du budget', style: TextStyle(color: KP.textMuted(d), fontSize: 11)),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: pct > 0.8 ? KP.danger : KP.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: KP.cardSoft(d),
              valueColor: AlwaysStoppedAnimation(pct > 0.8 ? KP.danger : KP.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
      String val,
      String label,
      Color color,
      IconData icon,
      bool d,
      ) =>
      Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              color: KP.text(d),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: KP.textMuted(d),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      );

  Widget _buildRecentExpenses(bool d) {
    if (_loadingExpenses) return const Center(child: CircularProgressIndicator());
    if (_expenses.isEmpty)
      return _emptyState('Aucune dépense', Icons.inbox_rounded, d);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Dépenses récentes',
              style: TextStyle(
                color: KP.text(d),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showAddExpenseSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: KP.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 13, color: KP.primary),
                    const SizedBox(width: 5),
                    const Text(
                      'Ajouter',
                      style: TextStyle(
                        color: KP.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._expenses.take(5).map((e) => _buildExpenseCard(e, d)),
      ],
    );
  }

  Widget _buildExpensesTab(bool d) {
    if (_loadingExpenses)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Toutes les dépenses',
                style: TextStyle(
                  color: KP.text(d),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAddExpenseSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: KP.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: KP.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: KP.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: _expenses.isEmpty
              ? Center(
            child: _emptyState('Aucune dépense', Icons.inbox_rounded, d),
          )
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: _expenses.map((e) => _buildExpenseCard(e, d)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetsTab(bool d) {
    if (_loadingBudgets)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Budgets par projet',
                style: TextStyle(
                  color: KP.text(d),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAddBudgetSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: KP.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: KP.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: KP.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: _budgets.isEmpty
              ? Center(
            child: _emptyState('Aucun budget', Icons.trending_up_rounded, d),
          )
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: _budgets.map((b) => _buildBudgetCard(b, d)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersTab(bool d) {
    if (_loadingReminders)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Rappels de paiement',
                style: TextStyle(
                  color: KP.text(d),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAddReminderSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: KP.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: KP.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: KP.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: _reminders.isEmpty
              ? Center(
            child: _emptyState('Aucun paiement', Icons.notifications_off_rounded, d),
          )
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: _reminders.map((r) => _buildReminderCard(r, d)).toList(),
          ),
        ),
      ],
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
              color: _getCategoryColor(category).withOpacity(0.12),
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
                    Icon(Icons.schedule_rounded, size: 12, color: KP.textMuted(d)),
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
  Widget _buildBudgetCard(dynamic budget, bool d) {
    final category = (_readValue(budget, 'category') ?? 'Unknown').toString();
    final limit = (_readValue(budget, 'limit') as num?)?.toDouble() ?? 0.0;
    final spent = (_readValue(budget, 'spent') as num?)?.toDouble() ?? 0.0;
    final currency = (_readValue(budget, 'currency') ?? 'TND').toString();

    final percentage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final color =
    percentage > 0.8 ? KP.danger : percentage > 0.5 ? KP.warning : KP.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(d),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KP.border(d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: KP.text(d),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: KP.cardSoft(d),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${spent.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)} $currency',
            style: TextStyle(color: KP.textMuted(d), fontSize: 11),
          ),
        ],
      ),
    );
  }
  Widget _buildReminderCard(dynamic reminder, bool d) {
    final title = (_readValue(reminder, 'title') ?? 'Unnamed').toString();
    final status = (_readValue(reminder, 'status') ?? 'pending').toString();
    final amount =
        (_readValue(reminder, 'amount') as num?)?.toDouble() ?? 0.0;

    final dueDate = _safeDate(_readValue(reminder, 'dueDate'));

    final isOverdue =
        status == 'pending' && dueDate.isBefore(DateTime.now());

    final reminderId =
        _readValue(reminder, '_id') ?? _readValue(reminder, 'id');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(d),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue ? KP.danger.withOpacity(0.3) : KP.border(d),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isOverdue
                      ? KP.danger.withOpacity(0.12)
                      : KP.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOverdue
                      ? Icons.priority_high_rounded
                      : Icons.notifications_rounded,
                  color: isOverdue ? KP.danger : KP.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: status == 'paid'
                            ? KP.textMuted(d)
                            : KP.text(d),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        decoration: status == 'paid'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12, color: KP.textMuted(d)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEE dd MMM', 'fr_FR')
                              .format(dueDate),
                          style: TextStyle(
                              color: KP.textMuted(d), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amount DT',
                    style: TextStyle(
                      color: isOverdue ? KP.danger : KP.text(d),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (status != 'paid')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? KP.danger.withOpacity(0.12)
                            : KP.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOverdue ? 'RETARD' : 'À VENIR',
                        style: TextStyle(
                          color: isOverdue
                              ? KP.danger
                              : KP.warning,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KP.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PAYÉ',
                        style: TextStyle(
                          color: KP.success,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _markReminderPaid(reminderId),
                style: FilledButton.styleFrom(
                  backgroundColor: KP.primary,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Mark as Paid',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
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
                style: TextStyle(
                  color: KP.textMuted(d),
                  fontSize: 15,
                ),
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