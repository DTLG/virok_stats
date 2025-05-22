import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/order_analysis.dart';

class OrderAnalysisDetailsPage extends StatefulWidget {
  final String factoryName;
  final Map<String, Map<String, OrderAnalysis>> factoryData;

  const OrderAnalysisDetailsPage({
    Key? key,
    required this.factoryName,
    required this.factoryData,
  }) : super(key: key);

  @override
  State<OrderAnalysisDetailsPage> createState() =>
      _OrderAnalysisDetailsPageState();
}

class _OrderAnalysisDetailsPageState extends State<OrderAnalysisDetailsPage>
    with SingleTickerProviderStateMixin {
  String _selectedStatistic = 'count';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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

  void _onStatisticChanged(String newStatistic) {
    setState(() {
      _selectedStatistic = newStatistic;
    });
    _animationController.forward(from: 0.0);
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}м';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}к';
    }
    return number.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.factoryName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSummaryCard(),
            // const SizedBox(height: 24),
            // SizedBox(
            //   height: 300,
            //   child: AnimatedBuilder(
            //     animation: _animation,
            //     builder: (context, child) {
            //       return PieChart(
            //         PieChartData(
            //           sections: _buildPieChartSections().map((section) {
            //             return PieChartSectionData(
            //               color: section.color,
            //               value: section.value * _animation.value,
            //               title: section.title,
            //               radius: section.radius,
            //               titleStyle: section.titleStyle,
            //               showTitle: section.showTitle,
            //               titlePositionPercentageOffset:
            //                   section.titlePositionPercentageOffset,
            //             );
            //           }).toList(),
            //           sectionsSpace: 2,
            //           centerSpaceRadius: 40,
            //           startDegreeOffset: -90,
            //         ),
            //       );
            //     },
            //   ),
            // ),
            // const SizedBox(height: 24),
            _buildDetailedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    double totalCount = 0;
    double totalAmountStorage = 0;
    double totalReserv = 0;
    double totalSumPrice = 0;

    widget.factoryData.forEach((date, orders) {
      orders.forEach((orderId, order) {
        totalCount += order.count;
        totalAmountStorage += order.amountStorage;
        totalReserv += order.reserv;
        totalSumPrice += order.sumPrice;
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
                  'Кількість',
                  totalCount.toStringAsFixed(0),
                  Icons.inventory_2_outlined,
                  'count',
                ),
                _buildStatItem(
                  'На складі',
                  totalAmountStorage.toStringAsFixed(0),
                  Icons.warehouse_outlined,
                  'storage',
                ),
                _buildStatItem(
                  'Резерв',
                  totalReserv.toStringAsFixed(0),
                  Icons.lock_outline,
                  'reserv',
                ),
                _buildStatItem(
                  'Сума',
                  '₴${totalSumPrice.toStringAsFixed(2)}',
                  Icons.attach_money,
                  'price',
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
    final isSelected = false;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
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
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    Map<String, double> dateTotals = {};

    widget.factoryData.forEach((date, orders) {
      double total = 0;
      orders.forEach((orderId, order) {
        switch (_selectedStatistic) {
          case 'count':
            total += order.count;
            break;
          case 'storage':
            total += order.amountStorage;
            break;
          case 'reserv':
            total += order.reserv;
            break;
          case 'price':
            total += order.sumPrice;
            break;
        }
      });
      dateTotals[date] = total;
    });

    double totalAll = dateTotals.values.fold(0, (sum, value) => sum + value);

    dateTotals.forEach((date, total) {
      final percentage =
          totalAll > 0 ? (total / totalAll * 100).toStringAsFixed(1) : '0.0';

      sections.add(
        PieChartSectionData(
          color: colors[sections.length % colors.length],
          value: total,
          title: '$date\n$percentage%\n(${_formatNumber(total)})',
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

  Widget _buildDetailedList() {
    // Збираємо всі товари в один список
    final List<_OrderRow> rows = [];
    double totalCount = 0;
    double totalSum = 0;

    widget.factoryData.forEach((date, orders) {
      orders.forEach((orderId, order) {
        rows.add(_OrderRow(
          name: order.name,
          article: orderId,
          storage: order.amountStorage,
          count: order.count,
          sum: order.sumPrice,
        ));
        totalCount += order.count;
        totalSum += order.sumPrice;
      });
    });

    return Card(
      // elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(140), // Номенклатура
            1: FixedColumnWidth(90), // Артикул
            2: FixedColumnWidth(90), // Залишок
            3: FixedColumnWidth(70), // Кількість
            4: FixedColumnWidth(110), // Сума
          },
          border: TableBorder.symmetric(
            inside: const BorderSide(width: 0.5, color: Colors.black12),
            outside: const BorderSide(width: 1, color: Colors.black26),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: Colors.yellow[100]),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Номенклатура',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Артикул',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Залишок на складі',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Кількість',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Сума коригувань',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            // Data rows
            ...rows.map((row) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        row.name,
                        maxLines: null,
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(row.article),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(row.storage.toStringAsFixed(0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(row.count > 0
                          ? '-${row.count.toStringAsFixed(0)}'
                          : row.count.toStringAsFixed(0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(row.sum > 0
                          ? '-${row.sum.toStringAsFixed(2)}'
                          : row.sum.toStringAsFixed(2)),
                    ),
                  ],
                )),
            // Total row
            TableRow(
              decoration: BoxDecoration(color: Colors.yellow[100]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Разом',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Padding(padding: EdgeInsets.all(8), child: Text('')),
                const Padding(padding: EdgeInsets.all(8), child: Text('')),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    totalCount > 0
                        ? '-${totalCount.toStringAsFixed(0)}'
                        : totalCount.toStringAsFixed(0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    totalSum > 0
                        ? '-${totalSum.toStringAsFixed(2)}'
                        : totalSum.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Допоміжний клас для зручності
class _OrderRow {
  final String name;
  final String article;
  final double storage;
  final double count;
  final double sum;
  _OrderRow(
      {required this.name,
      required this.article,
      required this.storage,
      required this.count,
      required this.sum});
}
