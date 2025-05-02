import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final String? note;

  Transaction({
    String? id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.toString(),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      note: map['note'],
    );
  }
}
