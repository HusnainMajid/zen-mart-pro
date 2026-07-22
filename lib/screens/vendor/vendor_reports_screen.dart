import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_report_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../utils/snackbar_helper.dart';

class VendorReportsScreen extends StatefulWidget {
  const VendorReportsScreen({super.key});

  @override
  State<VendorReportsScreen> createState() => _VendorReportsScreenState();
}

class _VendorReportsScreenState extends State<VendorReportsScreen> {
  String _selectedPeriod = 'Daily';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  void _loadReport() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.shopId != null) {
      final provider = context.read<VendorReportProvider>();
      if (_selectedPeriod == 'Daily') {
        provider.generateDailyReport(user.shopId!);
      } else if (_selectedPeriod == 'Weekly') {
        provider.generateWeeklyReport(user.shopId!);
      } else {
        provider.generateMonthlyReport(user.shopId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<VendorReportProvider>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        actions: [
          if (reportProvider.currentReport != null)
            IconButton(
              onPressed: reportProvider.isExporting ? null : () => _exportReport(reportProvider),
              icon: reportProvider.isExporting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              tooltip: 'Download PDF',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: reportProvider.isLoading
                ? const LoadingWidget()
                : reportProvider.currentReport == null
                    ? const EmptyStateWidget(message: 'No report data available')
                    : RefreshIndicator(
                        onRefresh: () async => _loadReport(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryCards(isTablet, reportProvider),
                              const SizedBox(height: 24),
                              const Text(
                                'Revenue Performance',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildRevenueChart(reportProvider),
                              const SizedBox(height: 24),
                              const Text(
                                'Best Selling Products',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildBestSellers(reportProvider),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(VendorReportProvider reportProvider) async {
    final success = await reportProvider.exportToPdf();
    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, 'Report exported to PDF');
    } else {
      SnackBarHelper.showError(
        context,
        reportProvider.errorMessage ?? 'Failed to export report',
      );
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Daily', label: Text('Today')),
          ButtonSegment(value: 'Weekly', label: Text('Weekly')),
          ButtonSegment(value: 'Monthly', label: Text('Monthly')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
          });
          _loadReport();
        },
      ),
    );
  }

  Widget _buildSummaryCards(bool isTablet, VendorReportProvider provider) {
    final report = provider.currentReport!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard('Total Revenue', '\$${report.totalRevenue.toStringAsFixed(2)}', Icons.payments, Colors.green),
        _buildReportCard('Total Orders', '${report.totalOrders}', Icons.shopping_bag, Colors.blue),
        _buildReportCard('Completed', '${report.completedOrders}', Icons.check_circle, Colors.teal),
        _buildReportCard('Cancelled', '${report.cancelledOrders}', Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(VendorReportProvider provider) {
    // This is a simplified chart representation since we don't have historical data in the model yet
    // In a real app, SalesReportModel would have a list of data points
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1000,
              barTouchData: BarTouchData(enabled: true),
              titlesData: const FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _getTitles)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 600, color: Colors.blue, width: 20)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 800, color: Colors.blue, width: 20)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 400, color: Colors.blue, width: 20)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 900, color: Colors.blue, width: 20)]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 700, color: Colors.blue, width: 20)]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _getTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0: text = 'Mon'; break;
      case 1: text = 'Tue'; break;
      case 2: text = 'Wed'; break;
      case 3: text = 'Thu'; break;
      case 4: text = 'Fri'; break;
      default: text = ''; break;
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  Widget _buildBestSellers(VendorReportProvider provider) {
    final bestSellers = provider.currentReport!.bestSellingProducts;
    if (bestSellers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No sales data for products yet')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bestSellers.length,
      itemBuilder: (context, index) {
        final product = bestSellers[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
            title: Text(product['name'] ?? 'Product'),
            subtitle: Text('Sold: ${product['quantity'] ?? 0} units'),
            trailing: Text(
              '\$${(product['revenue'] ?? 0.0).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );
      },
    );
  }
}
