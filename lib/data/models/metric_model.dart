import 'package:flutter/material.dart';
import '../../domain/entities/metric.dart';
import '../../core/constants/app_colors.dart';

class MetricModel extends Metric {
  const MetricModel({
    required String title,
    required List<num> data,
    required List<String> labels,
    required Color color,
  }) : super(
          title: title,
          data: data,
          labels: labels,
          color: color,
        );

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    return MetricModel(
      title: json['title'] as String,
      data: List<num>.from(json['data']),
      labels: List<String>.from(json['labels']),
      color: AppColors.metricColors[json['title']] ?? Colors.grey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'data': data,
      'labels': labels,
    };
  }
}
