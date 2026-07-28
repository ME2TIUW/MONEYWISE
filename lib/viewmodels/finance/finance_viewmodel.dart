import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:money_wise/data/services/user_service.dart';
import 'package:money_wise/domain/entities/transaction_entity.dart';
import 'package:money_wise/data/services/transaction_service.dart';
import 'package:intl/intl.dart';

class FinanceViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;

  String? _amountErrorMessage;
  String? _categoryErrorMessage;

  String? get amountErrorMessage => _amountErrorMessage;
  String? get categoryErrorMessage => _categoryErrorMessage;

  final List<String> categories = [
    'Food & Drinks',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Health',
    'Income/Salary',
    'Others',
  ];

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? _selectedFilterMonth;
  TransactionType? _selectedFilterType;
  String? _selectedFilterCategory;

  DateTime? get selectedFilterMonth => _selectedFilterMonth;
  TransactionType? get selectedFilterType => _selectedFilterType;
  String? get selectedFilterCategory => _selectedFilterCategory;

  bool get hasActiveFilters =>
      _selectedFilterMonth != null ||
      _selectedFilterType != null ||
      _selectedFilterCategory != null;

  void setFilterMonth(DateTime? month) {
    _selectedFilterMonth = month;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _selectedFilterType = type;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _selectedFilterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _selectedFilterMonth = null;
    _selectedFilterType = null;
    _selectedFilterCategory = null;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return _allTransactions.where((t) {
      bool matchesMonth = true;
      if (_selectedFilterMonth != null) {
        matchesMonth =
            t.date.year == _selectedFilterMonth!.year &&
            t.date.month == _selectedFilterMonth!.month;
      }

      bool matchesType = true;
      if (_selectedFilterType != null) {
        matchesType = t.type == _selectedFilterType;
      }

      bool matchesCategory = true;
      if (_selectedFilterCategory != null) {
        matchesCategory = t.category == _selectedFilterCategory;
      }

      return matchesMonth && matchesType && matchesCategory;
    }).toList();
  }

  List<DateTime> get availableFilterMonths {
    final Set<String> uniqueMonths = {};
    final List<DateTime> result = [];

    for (var t in _allTransactions) {
      String key = "${t.date.year}-${t.date.month}";
      if (!uniqueMonths.contains(key)) {
        uniqueMonths.add(key);
        result.add(DateTime(t.date.year, t.date.month));
      }
    }
    result.sort((a, b) => b.compareTo(a));
    return result;
  }

  List<TransactionItem> _lineItems = [];
  List<TransactionItem> get lineItems => _lineItems;

  void addLineItem() {
    _lineItems.add(TransactionItem(name: "", quantity: 1, price: 0));
    notifyListeners();
  }

  void removeLineItem(int index) {
    _lineItems.removeAt(index);
    _calculateTotalFromItems();
    notifyListeners();
  }

  void updateLineItem(int index, {String? name, int? qty, double? price}) {
    if (name != null) _lineItems[index].name = name;
    if (qty != null) _lineItems[index].quantity = qty;
    if (price != null) _lineItems[index].price = price;
    _calculateTotalFromItems();
    notifyListeners();
  }

  void _calculateTotalFromItems() {
    if (_lineItems.isEmpty) return;
    double total = 0;
    for (var item in _lineItems) {
      total += (item.price * item.quantity);
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    amountController.text = formatter.format(total);
    validateAmount(total.toString());
  }

  void reset() {
    amountController.clear();
    merchantController.clear();
    noteController.clear();
    _lineItems.clear();
    _selectedCategory = null;
    _selectedDate = DateTime.now();
    _amountErrorMessage = null;
    _categoryErrorMessage = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    amountController.dispose();
    merchantController.dispose();
    noteController.dispose();
    super.dispose();
  }

  final List<TransactionModel> _allTransactions = [];
  List<TransactionModel> get allTransactions => _allTransactions;

  late DateTimeRange _dateRange;

  FinanceViewModel() {
    _initializeDateRange();
  }

  double _monthlyBudget = 0.0;
  double get monthlyBudget => _monthlyBudget;
  double get remainingBudget =>
      (_monthlyBudget + currentMonthIncome) - currentMonthExpenses;

  Future<void> fetchUserBudget() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userData = await _userService.getUserByUid(user.uid);
      if (userData != null) {
        _monthlyBudget = userData.monthlyBudget ?? 0.0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching budget: $e");
    }
  }

  bool willExceedBudget(double newAmount) {
    return (remainingBudget - newAmount) < 0;
  }

  void _initializeDateRange() {
    DateTime now = DateTime.now();

    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  DateTimeRange get dateRange => _dateRange;

  void updateDateRange(DateTimeRange newRange) {
    _dateRange = newRange;
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    validateCategory(category);
    notifyListeners();
  }

  void validateAmount(String amount) {
    final parsed = double.tryParse(amount);
    _amountErrorMessage = (amount.isEmpty || parsed == null || parsed < 0)
        ? 'Please enter a valid amount.'
        : null;
    notifyListeners();
  }

  void validateCategory(String? category) {
    _categoryErrorMessage = (category == null) ? 'Category is required.' : null;
    notifyListeners();
  }

  double get currentMonthExpenses {
    final now = DateTime.now();
    return _allTransactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get lastMonthExpense {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);

    return _allTransactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.month == lastMonth.month &&
              t.date.year == lastMonth.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentMonthIncome {
    final now = DateTime.now();
    return _allTransactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get lastMonthIncome {
    final now = DateTime.now();
    final lastmonth = DateTime(now.year, now.month - 1);

    return _allTransactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.month == lastmonth.month &&
              t.date.year == lastmonth.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get expenseChangePercent {
    if (lastMonthExpense == 0) {
      if (currentMonthExpenses == 0) return 0;
      return 100;
    }
    ;
    return ((currentMonthExpenses - lastMonthExpense) / lastMonthExpense) * 100;
  }

  double get incomeChangePercent {
    if (lastMonthIncome == 0) {
      if (currentMonthIncome == 0) return 0;
      return 100;
    }
    ;
    return ((currentMonthIncome - lastMonthIncome) / lastMonthIncome) * 100;
  }

  double get totalBalance {
    double totalIncome = _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    double totalExpense = _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return totalIncome - totalExpense;
  }

  Future<bool> addTransaction(TransactionType type) async {
    validateAmount(amountController.text.replaceAll('.', ''));
    validateCategory(_selectedCategory);

    if (_amountErrorMessage != null || _categoryErrorMessage != null)
      return false;

    isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      double amountValue =
          double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;

      final newTransaction = TransactionModel(
        id: '',
        amount: amountValue,
        type: type,
        category: _selectedCategory!,
        merchant: merchantController.text.trim().isEmpty
            ? null
            : merchantController.text.trim(),
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        date: _selectedDate,
        isVerified: true,
        createdAt: DateTime.now(),
        items: List.from(_lineItems),
      );

      await _transactionService.addTransaction(user.uid, newTransaction);

      await fetchTransactions();
      reset();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editTransaction(
    String transactionId,
    TransactionModel updatedTransaction,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final oldTransaction = _allTransactions.firstWhere(
        (t) => t.id == transactionId,
      );

      await _transactionService.updateTransaction(
        user.uid,
        oldTransaction, 
        updatedTransaction,
      );

      await fetchUserBudget(); 
      await fetchTransactions();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final transactionToDelete = _allTransactions.firstWhere(
        (t) => t.id == transactionId,
      );

      await _transactionService.deleteTransaction(
        user.uid,
        transactionToDelete,
      );

      await fetchTransactions();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadTransactionForEdit(TransactionModel transaction) {
    reset();
    amountController.text = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(transaction.amount);
    merchantController.text = transaction.merchant ?? '';
    noteController.text = transaction.note ?? '';
    _selectedCategory = transaction.category;
    _selectedDate = transaction.date;
    _lineItems = List.from(transaction.items);
    notifyListeners();
  }

  Map<String, double> get groupedCategorySpending {
    Map<String, double> totals = {};

    int startInt =
        _dateRange.start.year * 10000 +
        _dateRange.start.month * 100 +
        _dateRange.start.day;
    int endInt =
        _dateRange.end.year * 10000 +
        _dateRange.end.month * 100 +
        _dateRange.end.day;

    final filteredList = _allTransactions.where((t) {
      final isExpense = t.type == TransactionType.expense;

      int tInt = t.date.year * 10000 + t.date.month * 100 + t.date.day;

      bool isWithinRange = tInt >= startInt && tInt <= endInt;

      return isExpense && isWithinRange;
    });

    for (var t in filteredList) {
      totals.update(
        t.category,
        (val) => val + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  Future<void> fetchTransactions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); 

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User is not authenticated.');

      final List<TransactionModel> transactions = await _transactionService
          .getTransactions(user.uid)
          .first;

      _allTransactions.clear();
      _allTransactions.addAll(transactions);
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      _allTransactions.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransactionFromReceipt({
    String? merchant,
    DateTime? date,
    required double amount,
    List<TransactionItem>? items,
    String? category,
  }) async {
    if (amount <= 0) {
      errorMessage = 'Amount must be greater than zero.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final txModel = TransactionModel(
        id: '',
        amount: amount,
        type: TransactionType.expense,
        category: category ?? 'Others',
        merchant: merchant,
        receiptUrl: null,
        date: DateTime.now(),
        note: null,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: null,
        items: items ?? [],
      );

      await _transactionService.addTransaction(user.uid, txModel);
      await fetchTransactions();

      await fetchTransactions();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
