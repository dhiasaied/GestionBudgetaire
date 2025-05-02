import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  DateTime _selectedMonth = DateTime.now();
  String? _userId;
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  List<Transaction> get transactions => _transactions;
  DateTime get selectedMonth => _selectedMonth;

  void updateUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadTransactions();
    } else {
      _transactions = [];
      notifyListeners();
    }
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  double getSpendingForCategory(String categoryId) {
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getSpendingByCategory() {
    final Map<String, double> spending = {};
    for (var transaction in _transactions.where((t) => t.type == TransactionType.expense)) {
      spending[transaction.categoryId] = (spending[transaction.categoryId] ?? 0.0) + transaction.amount;
    }
    return spending;
  }

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        map[transaction.categoryId] = (map[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }
    return map;
  }

  Map<String, double> get incomeByCategory {
    final map = <String, double>{};
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        map[transaction.categoryId] = (map[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }
    return map;
  }

  Map<DateTime, double> getMonthlyBalances() {
    final Map<DateTime, double> monthlyBalances = {};
    if (_transactions.isEmpty) return monthlyBalances;

    // Trier les transactions par date
    final sortedTransactions = List<Transaction>.from(_transactions);
    sortedTransactions.sort((a, b) => a.date.compareTo(b.date));

    // Trouver le premier et le dernier mois
    final firstDate = DateTime(sortedTransactions.first.date.year, sortedTransactions.first.date.month);
    final lastDate = DateTime(sortedTransactions.last.date.year, sortedTransactions.last.date.month);

    // Initialiser tous les mois avec un solde de 0
    var currentDate = firstDate;
    while (!currentDate.isAfter(lastDate)) {
      monthlyBalances[currentDate] = 0;
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Calculer le solde pour chaque mois
    double runningBalance = 0;
    for (var transaction in sortedTransactions) {
      final monthStart = DateTime(transaction.date.year, transaction.date.month);
      runningBalance += transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      monthlyBalances[monthStart] = runningBalance;
    }

    return monthlyBalances;
  }

  Future<void> loadTransactions() async {
    if (_userId == null) return;

    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    _transactions = snapshot.docs
        .map((doc) => Transaction.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .add(transaction.toMap());
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(id)
        .delete();
    await loadTransactions();
  }

  void changeMonth(DateTime month) {
    _selectedMonth = month;
    loadTransactions();
  }
}
