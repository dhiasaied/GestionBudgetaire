import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/providers/transaction_provider.dart';
import 'package:gestion_budgetaire/models/transaction.dart';

void main() {
  late TransactionProvider provider;

  setUp(() {
    provider = TransactionProvider();
  });

  group('TransactionProvider - Calculs de base', () {
    test('Calcul du solde total', () {
      // Arrange
      final transactions = [
        Transaction(
          id: '1',
          description: 'Salaire',
          amount: 2000,
          date: DateTime(2025, 5, 1),
          type: TransactionType.income,
          categoryId: 'salary',
        ),
        Transaction(
          id: '2',
          description: 'Loyer',
          amount: 800,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'housing',
        ),
        Transaction(
          id: '3',
          description: 'Courses',
          amount: 200,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
      ];

      // Act
      for (var transaction in transactions) {
        provider.addTransaction(transaction);
      }

      // Assert
      expect(provider.balance, 1000); // 2000 - 800 - 200
      expect(provider.totalIncome, 2000);
      expect(provider.totalExpenses, 1000);
    });

    test('Calcul des totaux par catégorie', () {
      // Arrange
      final transactions = [
        Transaction(
          id: '1',
          description: 'Courses 1',
          amount: 100,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
        Transaction(
          id: '2',
          description: 'Courses 2',
          amount: 150,
          date: DateTime(2025, 5, 2),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
        Transaction(
          id: '3',
          description: 'Restaurant',
          amount: 50,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'dining',
        ),
      ];

      // Act
      for (var transaction in transactions) {
        provider.addTransaction(transaction);
      }

      // Assert
      final expensesByCategory = provider.expensesByCategory;
      expect(expensesByCategory['groceries'], 250);
      expect(expensesByCategory['dining'], 50);
    });

    test('Calcul de l\'évolution mensuelle', () {
      // Arrange
      final transactions = [
        Transaction(
          id: '1',
          description: 'Salaire Janvier',
          amount: 2000,
          date: DateTime(2025, 1, 1),
          type: TransactionType.income,
          categoryId: 'salary',
        ),
        Transaction(
          id: '2',
          description: 'Loyer Janvier',
          amount: 800,
          date: DateTime(2025, 1, 15),
          type: TransactionType.expense,
          categoryId: 'housing',
        ),
        Transaction(
          id: '3',
          description: 'Salaire Février',
          amount: 2000,
          date: DateTime(2025, 2, 1),
          type: TransactionType.income,
          categoryId: 'salary',
        ),
        Transaction(
          id: '4',
          description: 'Loyer Février',
          amount: 800,
          date: DateTime(2025, 2, 15),
          type: TransactionType.expense,
          categoryId: 'housing',
        ),
      ];

      // Act
      for (var transaction in transactions) {
        provider.addTransaction(transaction);
      }

      // Assert
      final monthlyBalances = provider.getMonthlyBalances();
      expect(monthlyBalances[DateTime(2025, 1)], 1200); // 2000 - 800
      expect(monthlyBalances[DateTime(2025, 2)], 2400); // (2000 - 800) + (2000 - 800)
    });
  });

  group('TransactionProvider - Opérations CRUD', () {
    test('Ajout et suppression de transaction', () {
      // Arrange
      final transaction = Transaction(
        id: '1',
        description: 'Test',
        amount: 100,
        date: DateTime(2025, 5, 1),
        type: TransactionType.expense,
        categoryId: 'test',
      );

      // Act & Assert
      provider.addTransaction(transaction);
      expect(provider.transactions.length, 1);
      expect(provider.totalExpenses, 100);

      provider.deleteTransaction(transaction.id);
      expect(provider.transactions.length, 0);
      expect(provider.totalExpenses, 0);
    });

    test('Mise à jour de transaction', () {
      // Arrange
      final transaction = Transaction(
        id: '1',
        description: 'Test',
        amount: 100,
        date: DateTime(2025, 5, 1),
        type: TransactionType.expense,
        categoryId: 'test',
      );

      // Act
      provider.addTransaction(transaction);
      
      final updatedTransaction = Transaction(
        id: '1',
        description: 'Test modifié',
        amount: 150,
        date: DateTime(2025, 5, 1),
        type: TransactionType.expense,
        categoryId: 'test',
      );
      
      provider.updateTransaction(updatedTransaction);

      // Assert
      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.description, 'Test modifié');
      expect(provider.transactions.first.amount, 150);
      expect(provider.totalExpenses, 150);
    });
  });
}
