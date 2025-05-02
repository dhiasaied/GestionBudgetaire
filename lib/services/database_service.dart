import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/transaction.dart';
import '../models/budget_goal.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static sqflite.Database? _database;

  DatabaseService._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_goals (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        startDate TEXT NOT NULL
      )
    ''');
  }

  // Méthodes pour les transactions
  Future<void> createTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final db = await instance.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Méthodes pour les objectifs budgétaires
  Future<void> createBudgetGoal(BudgetGoal goal) async {
    final db = await instance.database;
    await db.insert('budget_goals', goal.toMap());
  }

  Future<List<BudgetGoal>> getBudgetGoals() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('budget_goals');
    return List.generate(maps.length, (i) => BudgetGoal.fromMap(maps[i]));
  }

  Future<List<BudgetGoal>> getBudgetGoalsByMonth(DateTime month) async {
    final db = await instance.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'budget_goals',
      where: 'startDate BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) => BudgetGoal.fromMap(maps[i]));
  }

  Future<void> deleteBudgetGoal(String id) async {
    final db = await instance.database;
    await db.delete(
      'budget_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateBudgetGoal(BudgetGoal goal) async {
    final db = await instance.database;
    await db.update(
      'budget_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
}
