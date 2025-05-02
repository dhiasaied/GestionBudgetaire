import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_goal_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/budget_goal.dart';
import '../models/budget_period.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs budgétaires'),
      ),
      body: Consumer3<CategoryProvider, BudgetGoalProvider, TransactionProvider>(
        builder: (context, categoryProvider, budgetProvider, transactionProvider, _) {
          final expenseCategories = categoryProvider.expenseCategories;
          final goals = budgetProvider.budgetGoals;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sélectionner une catégorie'),
                          ),
                          ...expenseCategories.map((category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                            if (value != null) {
                              final existingGoal = budgetProvider.getBudgetGoalForCategory(value, budgetProvider.selectedMonth);
                              if (existingGoal != null) {
                                _amountController.text = existingGoal.amount.toString();
                              } else {
                                _amountController.clear();
                              }
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une catégorie';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Montant maximum (DT)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final categoryId = _selectedCategoryId!;
                            final amount = double.parse(_amountController.text);
                            final existingGoal = budgetProvider.getBudgetGoalForCategory(categoryId, budgetProvider.selectedMonth);

                            if (existingGoal != null) {
                              await budgetProvider.updateBudgetGoal(
                                BudgetGoal(
                                  id: existingGoal.id,
                                  categoryId: categoryId,
                                  amount: amount,
                                  period: _selectedPeriod,
                                  startDate: budgetProvider.selectedMonth,
                                  userId: existingGoal.userId,
                                ),
                              );
                            } else {
                              await budgetProvider.addBudgetGoal(
                                BudgetGoal(
                                  categoryId: categoryId,
                                  amount: amount,
                                  period: _selectedPeriod,
                                  startDate: budgetProvider.selectedMonth,
                                  userId: '', // L'ID de l'utilisateur sera défini dans le provider
                                ),
                              );
                            }

                            setState(() {
                              _selectedCategoryId = null;
                              _amountController.clear();
                            });
                          }
                        },
                        child: const Text('Enregistrer l\'objectif'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final category = categoryProvider.getCategoryById(goal.categoryId);
                    if (category == null) return const SizedBox.shrink();

                    final spending = transactionProvider.getSpendingForCategory(goal.categoryId);
                    final progress = budgetProvider.getProgressForCategory(goal.categoryId, spending);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(category.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Objectif: ${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(goal.amount)}'),
                            Text('Dépensé: ${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(spending)}'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1 ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => budgetProvider.deleteBudgetGoal(goal.id),
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
    );
  }
}
