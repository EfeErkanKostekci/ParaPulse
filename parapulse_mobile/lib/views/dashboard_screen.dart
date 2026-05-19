import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import 'add_transaction_screen.dart';
import 'profile_screen.dart';
import '../core/currency_utils.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _timeFilter = 'Aylık';

  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    final filtered = _transactions.where((tx) {
      if (_timeFilter == 'Günlük') {
        return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
      } else if (_timeFilter == 'Haftalık') {
        return tx.date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_timeFilter == 'Aylık') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (_timeFilter == 'Yıllık') {
        return tx.date.year == now.year;
      }
      return true;
    }).toList();

    // Tarihe göre en yeniden en eskiye sıralama (Descending Sort)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  // Dynamic Colors
  Color get darkNavy => Theme.of(context).cardColor;
  Color get backgroundNavy => Theme.of(context).scaffoldBackgroundColor;
  Color get primaryGreen => Theme.of(context).primaryColor;
  Color get coralRed => Theme.of(context).colorScheme.error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final transactions = await _transactionService.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  double get _totalBalance {
    double balance = 0;
    for (var tx in _filteredTransactions) {
      if (tx.type == 'income') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  Map<String, double> get _categoryExpenses {
    Map<String, double> expenses = {};
    for (var tx in _filteredTransactions) {
      if (tx.type == 'expense') {
        expenses[tx.category] = (expenses[tx.category] ?? 0) + tx.amount;
      }
    }
    return expenses;
  }

  List<PieChartSectionData> _getChartSections() {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currency = currencyProvider.selectedCurrency;
    final rate = currencyProvider.currentRate;

    final expenses = _categoryExpenses;
    if (expenses.isEmpty) {
      return [
        PieChartSectionData(
          color: darkNavy.withOpacity(0.5),
          value: 1,
          title: '',
          radius: 50,
        )
      ];
    }

    final colors = [
      coralRed,
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
    ];

    int colorIndex = 0;
    return expenses.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: CurrencyUtils.formatAmount(entry.value, currency: currency, rate: rate),
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundNavy,
      appBar: AppBar(
        title: Text(
          'ParaPulse',
          style: GoogleFonts.outfit(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: _fetchTransactions,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchTransactions,
              color: primaryGreen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildTimeFilters(),
                  const SizedBox(height: 24),
                  _buildChartSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Son Harcamalar',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (result == true) {
            _fetchTransactions();
          }
        },
      ),
    );
  }

  Widget _buildTimeFilters() {
    final filters = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _timeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryGreen,
              backgroundColor: darkNavy,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _timeFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currency = currencyProvider.selectedCurrency;
    final rate = currencyProvider.currentRate;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [darkNavy, const Color(0xFF334155)]
              : [Colors.white, Colors.blueGrey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam Bakiye',
            style: GoogleFonts.inter(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyUtils.formatAmount(_totalBalance, currency: currency, rate: rate),
            style: GoogleFonts.outfit(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyBarChart() {
    final Map<int, double> monthlyExpenses = {};
    for (var i = 1; i <= 12; i++) monthlyExpenses[i] = 0;
    
    for (var tx in _filteredTransactions) {
      if (tx.type == 'expense') {
        monthlyExpenses[tx.date.month] = (monthlyExpenses[tx.date.month] ?? 0) + tx.amount;
      }
    }

    double maxVal = 1;
    for (var v in monthlyExpenses.values) { if (v > maxVal) maxVal = v; }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const titles = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titles[value.toInt() - 1],
                      style: GoogleFonts.inter(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: monthlyExpenses.entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: coralRed,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _timeFilter == 'Yıllık' ? 'Aylık Harcama Dağılımı' : 'Kategori Dağılımı',
            style: GoogleFonts.inter(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _timeFilter == 'Yıllık'
              ? _buildYearlyBarChart()
              : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _getChartSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

    Widget _buildTransactionsList() {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currency = currencyProvider.selectedCurrency;
    final rate = currencyProvider.currentRate;
    
    final txList = _filteredTransactions.toList(); // Artık reversed kullanmıyoruz, çünkü sıralı geliyor
    
    if (txList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Henüz harcama yok.',
            style: GoogleFonts.inter(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54),
          ),
        ),
      );
    }

    // --- YILLIK FİLTRELEME GÖRÜNÜMÜ ---
    if (_timeFilter == 'Yıllık') {
      final Map<int, double> monthlyTotals = {};
      final Map<int, double> monthlyIncomes = {};
      for (var tx in _filteredTransactions) {
        if (tx.type == 'expense') {
          monthlyTotals[tx.date.month] = (monthlyTotals[tx.date.month] ?? 0) + tx.amount;
        } else {
          monthlyIncomes[tx.date.month] = (monthlyIncomes[tx.date.month] ?? 0) + tx.amount;
        }
      }
      const monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      
      final activeMonths = monthlyTotals.keys.toSet().union(monthlyIncomes.keys.toSet()).toList()
        ..sort((a, b) => b.compareTo(a));

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activeMonths.length,
        itemBuilder: (context, index) {
          final month = activeMonths[index];
          final expense = monthlyTotals[month] ?? 0;
          final income = monthlyIncomes[month] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: primaryGreen.withOpacity(0.2),
                child: Icon(Icons.calendar_month, color: primaryGreen),
              ),
              title: Text(
                monthNames[month - 1],
                style: GoogleFonts.inter(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Gelir: ${CurrencyUtils.formatAmount(income, currency: currency, rate: rate)}',
                style: GoogleFonts.inter(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                '-${CurrencyUtils.formatAmount(expense, currency: currency, rate: rate)}',
                style: GoogleFonts.inter(
                  color: coralRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      );
    }

    // --- GÜNLÜK, HAFTALIK, AYLIK FİLTRELEME GÖRÜNÜMÜ ---
    // (Eğer filtre Yıllık değilse, elemanları tek tek ve tersten listeler)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txList.length,
      itemBuilder: (context, index) {
        final tx = txList[index];
        final isIncome = tx.type == 'income';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isIncome ? primaryGreen.withOpacity(0.2) : coralRed.withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? primaryGreen : coralRed,
              ),
            ),
            title: Text(
              tx.category,
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${tx.date.day}/${tx.date.month}/${tx.date.year}',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyUtils.formatAmount(tx.amount, currency: currency, rate: rate)}',
              style: GoogleFonts.inter(
                color: isIncome ? primaryGreen : coralRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}