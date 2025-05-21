import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/order_reserve.dart';
import '../../data/datasources/order_reserve_remote_data_source.dart';
import '../widgets/date_filter_buttons.dart';

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
  Map<String, Map<String, OrderReserve>> _data = {};
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
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
        _data = _filterDataByDateRange(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Map<String, Map<String, OrderReserve>> _filterDataByDateRange(
      Map<String, Map<String, OrderReserve>> data) {
    final filteredData = <String, Map<String, OrderReserve>>{};
    final startDate = _startDate.subtract(const Duration(days: 1));
    final endDate = _endDate;

    data.forEach((factory, dates) {
      filteredData[factory] = {};
      dates.forEach((date, reserve) {
        final analysisDate = DateTime.parse(date);
        if (analysisDate.isAfter(startDate) && analysisDate.isBefore(endDate)) {
          filteredData[factory]![date] = reserve;
        }
      });
    });

    return filteredData;
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _loadData();
    });
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
                    DateFilterButtons(
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateRangeChanged: _onDateRangeChanged,
                    ),
                    const SizedBox(height: 24),
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
                    _buildStatisticsContainers(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    int totalDelayCount = 0;
    int totalReservCount = 0;
    int totalDays = _endDate.difference(_startDate).inDays;

    _data.forEach((factory, dates) {
      dates.forEach((date, reserve) {
        totalDelayCount += reserve.delayCount;
        totalReservCount += reserve.reservCount;
      });
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
                  'Затримка',
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
                _buildStatItem(
                  'Днів',
                  (totalDays + 1).toString(),
                  Icons.calendar_today_outlined,
                  'days',
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
    final isDays = statType == 'days';

    final container = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected && !isDays
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected && !isDays
            ? Border.all(color: Theme.of(context).primaryColor)
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected && !isDays
                ? Theme.of(context).primaryColor
                : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  isSelected && !isDays ? Theme.of(context).primaryColor : null,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected && !isDays
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );

    if (isDays) {
      return container;
    }

    return InkWell(
      onTap: () => _onStatisticChanged(statType),
      child: container,
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
    ];

    int totalAll = 0;
    _data.forEach((factory, dates) {
      int total = 0;
      dates.forEach((date, reserve) {
        switch (_selectedStatistic) {
          case 'delay':
            total += reserve.delayCount;
            break;
          case 'reserv':
            total += reserve.reservCount;
            break;
        }
      });
      totalAll += total;
    });

    _data.forEach((factory, dates) {
      int total = 0;
      dates.forEach((date, reserve) {
        switch (_selectedStatistic) {
          case 'delay':
            total += reserve.delayCount;
            break;
          case 'reserv':
            total += reserve.reservCount;
            break;
        }
      });

      final percentage =
          totalAll > 0 ? (total / totalAll * 100).toStringAsFixed(1) : '0.0';

      sections.add(
        PieChartSectionData(
          color: colors[sections.length % colors.length],
          value: total.toDouble(),
          title: '$factory\n$percentage%\n(${_formatNumber(total)})',
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

  Widget _buildStatisticsContainers() {
    final colors = [
      Colors.red.withOpacity(0.2),
      Colors.blue.withOpacity(0.2),
      Colors.green.withOpacity(0.2),
    ];

    return Column(
      children: _data.entries.map((entry) {
        int totalDelayCount = 0;
        int totalReservCount = 0;

        entry.value.forEach((date, reserve) {
          totalDelayCount += reserve.delayCount;
          totalReservCount += reserve.reservCount;
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors[
                  _data.keys.toList().indexOf(entry.key) % colors.length],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors[
                        _data.keys.toList().indexOf(entry.key) % colors.length]
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
                  'Затримка: $totalDelayCount',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Резерв: $totalReservCount',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Кількість днів: ${entry.value.length}',
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
