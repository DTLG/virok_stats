import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final List<num> data;
  final List<String> labels;
  final Color color;
  final bool animated;

  const BarChart({
    Key? key,
    required this.data,
    required this.labels,
    required this.color,
    this.animated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxValue = 1;
        // double maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            data.length,
            (index) {
              double height =
                  (data[index] / maxValue) * constraints.maxHeight * 0.8;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: animated ? 500 : 0),
                    height: height,
                    width: constraints.maxWidth / (data.length * 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
