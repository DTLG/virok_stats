import 'package:flutter/material.dart';
import '../../domain/entities/metric.dart';
import '../../domain/repositories/metrics_repository.dart';

class MetricsProvider with ChangeNotifier {
  final MetricsRepository repository;
  List<Metric> _metrics = [];
  bool _isLoading = true;
  String _error = '';

  MetricsProvider({required this.repository}) {
    fetchMetrics();
  }

  List<Metric> get metrics => _metrics;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchMetrics() async {
    try {
      _isLoading = true;
      notifyListeners();

      _metrics = await repository.getMetrics();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
