import 'package:flutter/material.dart';

class Metric {
  final String title;
  final List<num> data;
  final List<String> labels;
  final Color color;

  const Metric({
    required this.title,
    required this.data,
    required this.labels,
    required this.color,
  });
}
