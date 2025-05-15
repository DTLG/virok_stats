import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'home/widgets/home_title.dart';
import '../../domain/models/table_analysis.dart';
import '../../data/datasources/all_tables_remote_data_source.dart';
import 'table_details_page.dart';
import '../widgets/date_filter_buttons.dart';

class TableAnalysisPage extends StatefulWidget {
  const TableAnalysisPage({Key? key}) : super(key: key);

  @override
  State<TableAnalysisPage> createState() => _TableAnalysisPageState();
}

class _TableAnalysisPageState extends State<TableAnalysisPage> {
  final AllTablesRemoteDataSource _service = AllTablesRemoteDataSourceImpl(
    client: http.Client(),
  );
  Map<String, List<TableAnalysis>> _data = {};
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _selectedStatistic = 'items';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAllTables();
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

  Map<String, List<TableAnalysis>> _filterDataByDateRange(
      Map<String, List<TableAnalysis>> data) {
    final filteredData = <String, List<TableAnalysis>>{};
    final startDate = _startDate.subtract(const Duration(days: 1));
    final endDate = _endDate;
    data.forEach((factory, analyses) {
      final filteredAnalyses = analyses.where((analysis) {
        final analysisDate = DateTime.parse(analysis.date);
        return analysisDate.isAfter(startDate) &&
            analysisDate.isBefore(endDate);
      }).toList();

      if (filteredAnalyses.isNotEmpty) {
        filteredData[factory] = filteredAnalyses;
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналіз відвантажених замовлень'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatisticsContainers(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    int totalItems = 0;
    int totalOrders = 0;
    int totalUniqueItems = 0;
    int totalDays = _endDate.difference(_startDate).inDays;

    _data.forEach((factory, analyses) {
      for (var analysis in analyses) {
        for (var table in analysis.tables) {
          totalItems += table.countItems;
          totalOrders += table.countOrder;
          totalUniqueItems += table.countUItems;
        }
      }
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
                  'Товарів',
                  totalItems.toString(),
                  Icons.inventory_2_outlined,
                  'items',
                ),
                _buildStatItem(
                  'Замовлень',
                  totalOrders.toString(),
                  Icons.shopping_cart_outlined,
                  'orders',
                ),
                // _buildStatItem(
                //   'Унікальних товарів',
                //   totalUniqueItems.toString(),
                //   Icons.category_outlined,
                //   'unique',
                // ),
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
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatistic = statType;
        });
      },
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
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
    ];

    int totalAll = 0;
    _data.forEach((factory, data) {
      int total = 0;
      for (var analysis in data) {
        for (var table in analysis.tables) {
          switch (_selectedStatistic) {
            case 'items':
              total += table.countItems;
              break;
            case 'orders':
              total += table.countOrder;
              break;
            case 'unique':
              total += table.countUItems;
              break;
          }
        }
      }
      totalAll += total;
    });

    _data.forEach((factory, data) {
      int total = 0;
      for (var analysis in data) {
        for (var table in analysis.tables) {
          switch (_selectedStatistic) {
            case 'items':
              total += table.countItems;
              break;
            case 'orders':
              total += table.countOrder;
              break;
            case 'unique':
              total += table.countUItems;
              break;
          }
        }
      }

      final percentage =
          totalAll > 0 ? (total / totalAll * 100).toStringAsFixed(1) : '0.0';

      sections.add(
        PieChartSectionData(
          color: colors[sections.length % colors.length],
          value: total.toDouble(),
          title: '$factory\n$percentage%',
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
        int totalItems = 0;
        int totalOrders = 0;
        int totalUniqueItems = 0;

        for (var analysis in entry.value) {
          for (var table in analysis.tables) {
            totalItems += table.countItems;
            totalOrders += table.countOrder;
            totalUniqueItems += table.countUItems;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TableDetailsPage(
                    factory: entry.key,
                    data: entry.value,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors[
                    _data.keys.toList().indexOf(entry.key) % colors.length],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors[_data.keys.toList().indexOf(entry.key) %
                          colors.length]
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
                    'Всього товарів: $totalItems',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Всього замовлень: $totalOrders',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Унікальних товарів: $totalUniqueItems',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Кількість днів: ${entry.value.length}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BadgeConnectorPainter extends CustomPainter {
  final Color color;

  BadgeConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
