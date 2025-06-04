import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/order_reserve.dart';
import '../../data/datasources/order_reserve_remote_data_source.dart';

class OrderReservePage extends StatefulWidget {
  const OrderReservePage({Key? key}) : super(key: key);

  @override
  State<OrderReservePage> createState() => _OrderReservePageState();
}

class _OrderReservePageState extends State<OrderReservePage>
    with SingleTickerProviderStateMixin {
  final OrderReserveRemoteDataSource _service =
      OrderReserveRemoteDataSourceImpl(
    client: http.Client(),
  );
  Map<String, OrderReserve>? _data;
  bool _isLoading = true;
  String _selectedStatistic = 'delay';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getOrderReserve();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _onStatisticChanged(String newStatistic) {
    setState(() {
      _selectedStatistic = newStatistic;
    });
    _animationController.forward(from: 0.0);
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}м';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}к';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналіз резервів'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
              _animationController.forward(from: 0.0);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
                _animationController.forward(from: 0.0);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return PieChart(
                            PieChartData(
                              sections: _buildPieChartSections().map((section) {
                                return PieChartSectionData(
                                  color: section.color,
                                  value: section.value * _animation.value,
                                  title: section.title,
                                  radius: section.radius,
                                  titleStyle: section.titleStyle,
                                  showTitle: section.showTitle,
                                  titlePositionPercentageOffset:
                                      section.titlePositionPercentageOffset,
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              startDegreeOffset: -90,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFactoryCards(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    if (_data == null) return const SizedBox.shrink();

    int totalDelayCount = 0;
    int totalReservCount = 0;

    _data!.forEach((factory, reserve) {
      totalDelayCount += reserve.delayCount;
      totalReservCount += reserve.reservCount;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Загальна статистика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Непроведено',
                  totalDelayCount.toString(),
                  Icons.timer_outlined,
                  'delay',
                ),
                _buildStatItem(
                  'Резерв',
                  totalReservCount.toString(),
                  Icons.lock_outline,
                  'reserv',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, String statType) {
    final isSelected = _selectedStatistic == statType;

    return InkWell(
      onTap: () => _onStatisticChanged(statType),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (_data == null) return [];

    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    int totalAll = 0;
    _data!.forEach((factory, reserve) {
      totalAll += _selectedStatistic == 'delay'
          ? reserve.delayCount
          : reserve.reservCount;
    });

    _data!.forEach((factory, reserve) {
      final value = _selectedStatistic == 'delay'
          ? reserve.delayCount
          : reserve.reservCount;
      final percentage =
          totalAll > 0 ? (value / totalAll * 100).toStringAsFixed(1) : '0.0';

      sections.add(
        PieChartSectionData(
          color: colors[sections.length % colors.length],
          value: value.toDouble(),
          title: '$factory\n$percentage%\n(${_formatNumber(value)})',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          showTitle: true,
          titlePositionPercentageOffset: 0.5,
        ),
      );
    });

    return sections;
  }

  Widget _buildFactoryCards() {
    if (_data == null) return const SizedBox.shrink();

    final colors = [
      Colors.red.withOpacity(0.2),
      Colors.blue.withOpacity(0.2),
      Colors.green.withOpacity(0.2),
      Colors.orange.withOpacity(0.2),
      Colors.purple.withOpacity(0.2),
    ];

    return Column(
      children: _data!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors[
                  _data!.keys.toList().indexOf(entry.key) % colors.length],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors[
                        _data!.keys.toList().indexOf(entry.key) % colors.length]
                    .withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Непроведено: ${entry.value.delayCount}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Резерв: ${entry.value.reservCount}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
