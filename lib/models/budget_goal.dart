import 'package:uuid/uuid.dart';
import 'budget_period.dart';

class BudgetGoal {
  final String id;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final String? userId;

  BudgetGoal({
    String? id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.userId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'userId': userId,
    };
  }

  factory BudgetGoal.fromMap(Map<String, dynamic> map) {
    return BudgetGoal(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      period: BudgetPeriod.values.firstWhere(
        (p) => p.toString() == map['period'],
      ),
      startDate: DateTime.parse(map['startDate']),
      userId: map['userId'],
    );
  }
}
