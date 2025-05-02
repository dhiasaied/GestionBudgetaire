import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Par catégorie'),
            Tab(text: 'Évolution mensuelle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CategoryReportTab(),
          MonthlyReportTab(),
        ],
      ),
    );
  }
}

class CategoryReportTab extends StatelessWidget {
  const CategoryReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, _) {
        final expensesByCategory = transactionProvider.expensesByCategory;
        final incomeByCategory = transactionProvider.incomeByCategory;
        
        if (expensesByCategory.isEmpty && incomeByCategory.isEmpty) {
          return const Center(
            child: Text('Aucune transaction à afficher'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Répartition des dépenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: expensesByCategory.entries.map((entry) {
                      final category = categoryProvider.getCategoryById(entry.key);
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${category?.name ?? 'Inconnu'}\n${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(entry.value)}',
                        color: Colors.primaries[expensesByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Répartition des revenus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: incomeByCategory.entries.map((entry) {
                      final category = categoryProvider.getCategoryById(entry.key);
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${category?.name ?? 'Inconnu'}\n${NumberFormat.currency(locale: 'fr_TN', symbol: 'DT').format(entry.value)}',
                        color: Colors.primaries[incomeByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MonthlyReportTab extends StatelessWidget {
  const MonthlyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final monthlyData = provider.getMonthlyBalances();
        
        if (monthlyData.isEmpty) {
          return const Center(
            child: Text('Aucune donnée à afficher'),
          );
        }

        final minY = monthlyData.values.reduce((a, b) => a < b ? a : b);
        final maxY = monthlyData.values.reduce((a, b) => a > b ? a : b);
        final padding = (maxY - minY) * 0.1;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Évolution du solde mensuel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              NumberFormat.compact(locale: 'fr_TN').format(value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                              final date = monthlyData.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MMM yy').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: monthlyData.length.toDouble() - 1,
                    minY: minY - padding,
                    maxY: maxY + padding,
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlyData.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.value,
                                ))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
