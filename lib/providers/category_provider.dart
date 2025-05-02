import 'package:flutter/foundation.dart' hide Category;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  String? _userId;
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.income).toList();
  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.expense).toList();

  void updateUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadCategories();
    } else {
      _categories = [];
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    if (_userId == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .get();

    _categories = snapshot.docs
        .map((doc) => Category.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    if (_userId == null) return;

    final docRef = await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .add(category.toMap());

    _categories.add(Category.fromMap({
      ...category.toMap(),
      'id': docRef.id,
    }));
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(id)
        .delete();

    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    return _categories.firstWhere((c) => c.id == id);
  }

  void initializeDefaultCategories() async {
    if (_userId == null) return;

    final defaultIncomeCategories = [
      Category(name: 'Salaire', type: CategoryType.income),
      Category(name: 'Remboursement', type: CategoryType.income),
      Category(name: 'Autre revenu', type: CategoryType.income),
    ];

    final defaultExpenseCategories = [
      Category(name: 'Alimentation', type: CategoryType.expense),
      Category(name: 'Transport', type: CategoryType.expense),
      Category(name: 'Loyer', type: CategoryType.expense),
      Category(name: 'Restaurant', type: CategoryType.expense),
      Category(name: 'Loisirs', type: CategoryType.expense),
      Category(name: 'Santé', type: CategoryType.expense),
    ];

    for (var category in [...defaultIncomeCategories, ...defaultExpenseCategories]) {
      await addCategory(category);
    }
  }
}
