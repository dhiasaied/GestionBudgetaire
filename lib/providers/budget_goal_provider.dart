import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/budget_goal.dart';
import '../models/budget_period.dart';

class BudgetGoalProvider with ChangeNotifier {
  List<BudgetGoal> _budgetGoals = [];
  String? _userId;
  DateTime _selectedMonth = DateTime.now();
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  List<BudgetGoal> get budgetGoals => _budgetGoals;
  DateTime get selectedMonth => _selectedMonth;

  void updateUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadBudgetGoals();
    } else {
      _budgetGoals = [];
      notifyListeners();
    }
  }

  Future<void> loadBudgetGoals() async {
    if (_userId == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('budgetGoals')
        .get();

    _budgetGoals = snapshot.docs
        .map((doc) => BudgetGoal.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
    notifyListeners();
  }

  Future<void> addBudgetGoal(BudgetGoal goal) async {
    if (_userId == null) return;

    final docRef = await _db
        .collection('users')
        .doc(_userId)
        .collection('budgetGoals')
        .add(goal.toMap());

    _budgetGoals.add(BudgetGoal.fromMap({
      ...goal.toMap(),
      'id': docRef.id,
    }));
    notifyListeners();
  }

  Future<void> updateBudgetGoal(BudgetGoal goal) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('budgetGoals')
        .doc(goal.id)
        .update(goal.toMap());

    final index = _budgetGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _budgetGoals[index] = goal;
      notifyListeners();
    }
  }

  Future<void> deleteBudgetGoal(String id) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('budgetGoals')
        .doc(id)
        .delete();

    _budgetGoals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    _selectedMonth = month;
    loadBudgetGoals();
  }

  BudgetGoal? getBudgetGoalForCategory(String categoryId, DateTime date) {
    try {
      return _budgetGoals.firstWhere(
        (goal) => goal.categoryId == categoryId &&
            goal.startDate.year == date.year &&
            goal.startDate.month == date.month &&
            (goal.period == BudgetPeriod.monthly ||
            (goal.period == BudgetPeriod.weekly &&
             (date.day - goal.startDate.day) < 7)),
      );
    } catch (e) {
      return null;
    }
  }

  double getRemainingBudget(String categoryId, DateTime date, double currentSpending) {
    final goal = getBudgetGoalForCategory(categoryId, date);
    if (goal == null) return 0;
    return goal.amount - currentSpending;
  }

  bool isOverBudget(String categoryId, DateTime date, double currentSpending) {
    return getRemainingBudget(categoryId, date, currentSpending) < 0;
  }

  double getProgressForCategory(String categoryId, double currentSpending) {
    final goal = getBudgetGoalForCategory(categoryId, _selectedMonth);
    if (goal == null) return 0;
    return (currentSpending / goal.amount).clamp(0.0, 1.0);
  }
}
