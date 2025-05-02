import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_budgetaire/providers/budget_goal_provider.dart';
import 'package:gestion_budgetaire/providers/transaction_provider.dart';
import 'package:gestion_budgetaire/models/budget_goal.dart';
import 'package:gestion_budgetaire/models/transaction.dart';
import 'package:gestion_budgetaire/models/budget_period.dart';

void main() {
  test('getBudgetGoalForCategory - test simple', () {
    final provider = BudgetGoalProvider();
    final goal = BudgetGoal(
      id: '1',
      categoryId: 'test',
      amount: 100,
      period: BudgetPeriod.monthly,
      startDate: DateTime(2025, 5, 1),
    );

    provider.addBudgetGoal(goal);

    final foundGoal = provider.getBudgetGoalForCategory('test', DateTime(2025, 5, 15));
    expect(foundGoal, isNotNull);
    expect(foundGoal?.id, '1');
    expect(foundGoal?.amount, 100);
  });

  late BudgetGoalProvider budgetGoalProvider;
  late TransactionProvider transactionProvider;

  setUp(() {
    budgetGoalProvider = BudgetGoalProvider();
    transactionProvider = TransactionProvider();
  });

  group('BudgetGoalProvider - Vérification des plafonds', () {
    test('Respect du plafond mensuel par catégorie', () {
      // Arrange
      final goal = BudgetGoal(
        id: '1',
        categoryId: 'groceries',
        amount: 500,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2025, 5, 1),
      );

      final transactions = [
        Transaction(
          id: '1',
          description: 'Courses semaine 1',
          amount: 200,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
        Transaction(
          id: '2',
          description: 'Courses semaine 2',
          amount: 150,
          date: DateTime(2025, 5, 8),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
      ];

      // Act
      budgetGoalProvider.addBudgetGoal(goal);
      for (var transaction in transactions) {
        transactionProvider.addTransaction(transaction);
      }

      // Assert
      final spending = transactionProvider.getSpendingForCategory('groceries');
      final remainingBudget = budgetGoalProvider.getRemainingBudget(
        'groceries',
        DateTime(2025, 5, 1),
        spending,
      );
      
      expect(spending, 350);
      expect(remainingBudget, 150); // 500 - 350
      expect(budgetGoalProvider.isOverBudget('groceries', DateTime(2025, 5, 1), spending), false);
    });

    test('Détection du dépassement de plafond', () {
      // Arrange
      final goal = BudgetGoal(
        id: '1',
        categoryId: 'dining',
        amount: 200,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2025, 5, 1),
      );

      final transactions = [
        Transaction(
          id: '1',
          description: 'Restaurant 1',
          amount: 100,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'dining',
        ),
        Transaction(
          id: '2',
          description: 'Restaurant 2',
          amount: 150,
          date: DateTime(2025, 5, 8),
          type: TransactionType.expense,
          categoryId: 'dining',
        ),
      ];

      // Act
      budgetGoalProvider.addBudgetGoal(goal);
      for (var transaction in transactions) {
        transactionProvider.addTransaction(transaction);
      }

      // Assert
      final spending = transactionProvider.getSpendingForCategory('dining');
      final remainingBudget = budgetGoalProvider.getRemainingBudget(
        'dining',
        DateTime(2025, 5, 1),
        spending,
      );
      
      expect(spending, 250);
      expect(remainingBudget, -50); // 200 - 250
      expect(budgetGoalProvider.isOverBudget('dining', DateTime(2025, 5, 1), spending), true);
    });

    test('Gestion des plafonds sur différentes périodes', () {
      // Arrange
      final monthlyGoal = BudgetGoal(
        id: '1',
        categoryId: 'entertainment',
        amount: 200,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2025, 5, 1),
      );

      final weeklyGoal = BudgetGoal(
        id: '2',
        categoryId: 'groceries',
        amount: 150,
        period: BudgetPeriod.weekly,
        startDate: DateTime(2025, 5, 1),
      );

      final transactions = [
        // Divertissement (mensuel)
        Transaction(
          id: '1',
          description: 'Cinéma semaine 1',
          amount: 50,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'entertainment',
        ),
        Transaction(
          id: '2',
          description: 'Cinéma semaine 2',
          amount: 50,
          date: DateTime(2025, 5, 8),
          type: TransactionType.expense,
          categoryId: 'entertainment',
        ),
        // Courses (hebdomadaire)
        Transaction(
          id: '3',
          description: 'Courses début de semaine',
          amount: 100,
          date: DateTime(2025, 5, 1),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
        Transaction(
          id: '4',
          description: 'Courses fin de semaine',
          amount: 80,
          date: DateTime(2025, 5, 4),
          type: TransactionType.expense,
          categoryId: 'groceries',
        ),
      ];

      // Act
      budgetGoalProvider.addBudgetGoal(monthlyGoal);
      budgetGoalProvider.addBudgetGoal(weeklyGoal);
      for (var transaction in transactions) {
        transactionProvider.addTransaction(transaction);
      }

      // Assert - Objectif mensuel
      final entertainmentSpending = transactionProvider.getSpendingForCategory('entertainment');
      expect(entertainmentSpending, 100);
      expect(
        budgetGoalProvider.getRemainingBudget(
          'entertainment',
          DateTime(2025, 5, 1),
          entertainmentSpending,
        ),
        100, // 200 - 100
      );
      expect(
        budgetGoalProvider.isOverBudget(
          'entertainment',
          DateTime(2025, 5, 1),
          entertainmentSpending,
        ),
        false,
      );

      // Assert - Objectif hebdomadaire
      final groceriesSpending = transactionProvider.getSpendingForCategory('groceries');
      expect(groceriesSpending, 180);
      expect(
        budgetGoalProvider.getRemainingBudget(
          'groceries',
          DateTime(2025, 5, 1),
          groceriesSpending,
        ),
        -30, // 150 - 180
      );
      expect(
        budgetGoalProvider.isOverBudget(
          'groceries',
          DateTime(2025, 5, 1),
          groceriesSpending,
        ),
        true,
      );
    });
  });
}
