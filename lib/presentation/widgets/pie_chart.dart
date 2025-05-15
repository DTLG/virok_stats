import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/pie_chart_provider.dart';
// import '../pages/all_failures_page.dart';

class PieChart extends StatefulWidget {
  final List<num> data;
  final List<String> labels;
  final List<Color> colors;
  final bool animated;
  final List<List<DateTime>> dates;
  final Function(String) onCategorySelected;
  final String categoryType;

  const PieChart({
    Key? key,
    required this.data,
    required this.labels,
    required this.colors,
    required this.dates,
    required this.onCategorySelected,
    required this.categoryType,
    this.animated = false,
  }) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PieChartProvider>().initializeLabels(widget.labels);
    });
  }

  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels != widget.labels) {
      context.read<PieChartProvider>().initializeLabels(widget.labels);
    }
  }

  List<num> get _filteredData {
    final provider = context.watch<PieChartProvider>();
    final List<num> filteredData = [];
    for (int i = 0; i < widget.data.length; i++) {
      if (provider.selectedLabels[widget.labels[i]] == true) {
        // Перевіряємо чи є хоча б одна дата в діапазоні для цієї групи
        final hasDateInRange =
            widget.dates[i].any((date) => provider.isDateInRange(date));
        filteredData.add(hasDateInRange ? widget.data[i] : 0);
      } else {
        filteredData.add(0);
      }
    }
    return filteredData;
  }

  Widget _buildLegend() {
    final provider = context.watch<PieChartProvider>();
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final allSelected =
                        provider.selectedLabels.values.every((value) => value);
                    provider.toggleAllLabels(!allSelected);
                  },
                  icon: Icon(
                    provider.selectedLabels.values.every((value) => value)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.blue,
                  ),
                  label: Text(
                    provider.selectedLabels.values.every((value) => value)
                        ? 'Сховати всі'
                        : 'Вибрати всі',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final total = _filteredData.reduce((a, b) => a + b);
              final percentage = total > 0
                  ? (_filteredData[index] / total * 100).toStringAsFixed(1)
                  : '0.0';
              final minutes = _filteredData[index].toStringAsFixed(1);

              return InkWell(
                onTap: () {
                  provider.setHoveredIndex(
                    provider.hoveredIndex == index ? null : index,
                  );
                  widget.onCategorySelected(widget.labels[index]);
                },
                onLongPress: () {
                  if (double.parse(minutes) > 0) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AllFailuresPage(
                    //       category: widget.labels[index],
                    //       categoryType: widget.categoryType,
                    //       startDate: provider.startDate,
                    //       endDate: provider.endDate,
                    //     ),
                    //   ),
                    // );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Дані відсутні'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.all(8),
                  color: provider.hoveredIndex == index
                      ? widget.colors[index]
                      : Colors.white,
                  child: Row(
                    children: [
                      Checkbox(
                        value: provider.selectedLabels[widget.labels[index]] ??
                            true,
                        onChanged: (bool? value) {
                          provider.toggleLabel(widget.labels[index], value);
                        },
                        activeColor: widget.colors[index],
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        color: widget.colors[index],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.labels[index]} | \t$percentage% | \t$minutes хв',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: widget.labels.length,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final provider = context.watch<PieChartProvider>();
    final total = _filteredData.fold<num>(0, (a, b) => a + b);
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.white,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                  size: const Size.square(220),
                  painter: PieChartPainter(
                    data: _filteredData,
                    colors: widget.colors,
                    hoveredIndex: provider.hoveredIndex,
                    gap: 8,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Загальний простій',
                  style: TextStyle(
                    color: Colors.blue[200],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${total % 1 == 0 ? total.toInt() : total.toStringAsFixed(2)} хв',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            children: [
              Expanded(
                child: _buildChart(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _buildLegend(),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildChart()),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: _buildLegend(),
              ),
            ],
          );
        }
      },
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<num> data;
  final List<Color> colors;
  final int? hoveredIndex;
  final double gap; // у градусах, наприклад 4-6

  PieChartPainter({
    required this.data,
    required this.colors,
    this.hoveredIndex,
    this.gap = 20, // градусів між секторами
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.fold<num>(0, (a, b) => a + b);
    if (total == 0) return;

    final thickness = radius * 0.15; // зменшена товщина кільця
    double startAngle = -math.pi / 2;
    final gapRadians = gap * math.pi / 180;
    final spacing = radius * 0.02; // відступ між лініями

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0) continue;
      final sweepAngle = 2 * math.pi * (data[i] / total) - gapRadians;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness *
            (i == hoveredIndex
                ? 1.2
                : 1.0) // збільшуємо товщину для вибраного сектора
        ..strokeCap = StrokeCap.round;

      // Малюємо тінь для вибраного сектора
      if (i == hoveredIndex) {
        final shadowPaint = Paint()
          ..color = colors[i].withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 1.4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawArc(
          Rect.fromCircle(
              center: center, radius: radius - thickness / 2 + spacing),
          startAngle + gapRadians / 2,
          sweepAngle > 0 ? sweepAngle : 0,
          false,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: radius - thickness / 2 + spacing),
        startAngle + gapRadians / 2,
        sweepAngle > 0 ? sweepAngle : 0,
        false,
        paint,
      );
      startAngle += 2 * math.pi * (data[i] / total);
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.colors != colors ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.gap != gap;
  }
}
