import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/analytics_provider.dart';
import '../../models/analytics_model.dart';
import '../../shared/widgets/loading_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            onPressed: () => context.read<AnalyticsProvider>().fetchAnalytics(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAnalytics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analytics = provider.analytics;
          if (analytics == null) {
            return const Center(child: Text('No analytics data available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCards(analytics),
                const SizedBox(height: 24),
                _buildCharts(analytics),
                const SizedBox(height: 24),
                _buildTopLists(analytics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopCards(AnalyticsModel analytics) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 3.5,
          children: [
            _StatCard(
              title: 'Total Revenue',
              value: currencyFormat.format(analytics.totalRevenue),
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Monthly Revenue',
              value: currencyFormat.format(analytics.monthlyRevenue),
              icon: Icons.calendar_month,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Daily Orders',
              value: analytics.dailyOrders.toString(),
              icon: Icons.today,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Pending Orders',
              value: analytics.pendingOrders.toString(),
              icon: Icons.pending_actions,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCharts(AnalyticsModel analytics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _RevenueChartCard()),
              const SizedBox(width: 16),
              Expanded(child: _OrderStatusChartCard(analytics: analytics)),
            ],
          );
        } else {
          return Column(
            children: [
              _RevenueChartCard(),
              const SizedBox(height: 16),
              _OrderStatusChartCard(analytics: analytics),
            ],
          );
        }
      },
    );
  }

  Widget _buildTopLists(AnalyticsModel analytics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _TopListCard(title: 'Top Selling Shops', items: analytics.topShops)),
              const SizedBox(width: 16),
              Expanded(child: _TopListCard(title: 'Top Vendors', items: analytics.topVendors, isVendor: true)),
              const SizedBox(width: 16),
              Expanded(child: _TopListCard(title: 'Top Customers', items: analytics.topCustomers)),
            ],
          );
        } else {
          return Column(
            children: [
              _TopListCard(title: 'Top Selling Shops', items: analytics.topShops),
              const SizedBox(height: 16),
              _TopListCard(title: 'Top Vendors', items: analytics.topVendors, isVendor: true),
              const SizedBox(height: 16),
              _TopListCard(title: 'Top Customers', items: analytics.topCustomers),
            ],
          );
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(25),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        // getTitlesWidget can be implemented for dates
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2, 2),
                        const FlSpot(4, 5),
                        const FlSpot(6, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(10, 3),
                        const FlSpot(12, 7),
                      ],
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withAlpha(25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusChartCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const _OrderStatusChartCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: analytics.completedOrders.toDouble(),
                      title: 'Completed',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: analytics.pendingOrders.toDouble(),
                      title: 'Pending',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: analytics.cancelledOrders.toDouble(),
                      title: 'Cancelled',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.green, text: 'Completed'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.orange, text: 'Pending'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.red, text: 'Cancelled'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _TopListCard extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final bool isVendor;

  const _TopListCard({
    required this.title,
    required this.items,
    this.isVendor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(isVendor ? (item['id'] ?? 'N/A') : (item['name'] ?? 'N/A')),
                    trailing: Text(
                      '${item['orders']} Orders',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
