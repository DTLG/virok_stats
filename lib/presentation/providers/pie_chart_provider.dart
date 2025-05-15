import 'package:flutter/material.dart';

class PieChartProvider extends ChangeNotifier {
  final Map<String, bool> _selectedLabels = {};
  int? _hoveredIndex;
  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, bool> get selectedLabels => _selectedLabels;
  int? get hoveredIndex => _hoveredIndex;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void initializeLabels(List<String> labels) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedLabels.clear();
      for (var label in labels) {
        _selectedLabels[label] = true;
      }
      notifyListeners();
    });
  }

  void toggleLabel(String label, bool? value) {
    _selectedLabels[label] = value ?? true;
    notifyListeners();
  }

  void toggleAllLabels(bool value) {
    for (var label in _selectedLabels.keys) {
      _selectedLabels[label] = value;
    }
    notifyListeners();
  }

  void setHoveredIndex(int? index) {
    _hoveredIndex = index;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  bool isDateInRange(DateTime date) {
    if (date.day == DateTime.now().day) {
      return true;
    }
    if (_startDate == null || _endDate == null) return true;
    final startOfDay =
        DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final endOfDay =
        DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
    return date.isAfter(startOfDay) && // ← Без віднімання дня
        date.isBefore(endOfDay);
  }
}
