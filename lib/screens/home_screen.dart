import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'budget_goals_screen.dart';
import 'reports_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Budgétaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetGoalsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: Provider.of<TransactionProvider>(context, listen: false)
                    .selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                if (!context.mounted) return;
                Provider.of<TransactionProvider>(context, listen: false)
                    .changeMonth(DateTime(picked.year, picked.month));
              }
            },
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, _) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  children: [
                    Text(
                      'Solde actuel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solde: ${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(transactionProvider.balance)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: transactionProvider.balance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Revenus: ${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(transactionProvider.totalIncome)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Dépenses: ${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(transactionProvider.totalExpenses)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactionProvider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactionProvider.transactions[index];
                    final category = categoryProvider.getCategoryById(transaction.categoryId);
                    if (category == null) return const SizedBox.shrink();

                    return Card(
                      child: ListTile(
                        title: Text(transaction.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category.name),
                            Text(
                              DateFormat.yMMMd().format(transaction.date),
                            ),
                            if (transaction.note != null)
                              Text(
                                transaction.note!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          NumberFormat.currency(locale: 'fr_TN', symbol: 'DT')
                              .format(transaction.amount),
                          style: TextStyle(
                            color: transaction.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
