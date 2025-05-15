import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/deformat_record.dart';

class DeformatProvider extends ChangeNotifier {
  List<DeformatRecord> _deformats = [];
  bool _isLoading = false;
  String _error = '';
  DateTime? _selectedDate;
  String _dateRangeType = 'today'; // 'today', 'week', 'custom'
  DateTime? _startDate;
  DateTime? _endDate;

  List<DeformatRecord> get deformats => _deformats;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime? get selectedDate => _selectedDate;
  String get dateRangeType => _dateRangeType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDateRange(String type, {DateTime? start, DateTime? end}) {
    _dateRangeType = type;
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  List<DeformatRecord> getFilteredDeformats() {
    if (_dateRangeType == 'all') return _deformats;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startOfRange;
    DateTime endOfRange;

    switch (_dateRangeType) {
      case 'today':
        startOfRange = today.subtract(const Duration(days: 1));
        endOfRange = DateTime(today.year, today.month, today.day, 23, 59, 59);
        break;
      case 'week':
        startOfRange = today.subtract(const Duration(days: 8));
        endOfRange = DateTime(today.year, today.month, today.day, 23, 59, 59);
        // startOfRange.add(const Duration(days: 7));
        break;
      case 'custom':
        if (_startDate == null || _endDate == null) return _deformats;
        startOfRange =
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        endOfRange = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        break;
      default:
        return _deformats;
    }

    return _deformats.where((record) {
      return record.date.isAfter(startOfRange) &&
          record.date.isBefore(endOfRange);
    }).toList();
  }

  Map<int, DeformatRecord> getGroupedDeformats() {
    final filteredDeformats = getFilteredDeformats();
    final Map<int, DeformatRecord> grouped = {};

    for (var record in filteredDeformats) {
      if (grouped.containsKey(record.iceLine)) {
        final existing = grouped[record.iceLine]!;
        grouped[record.iceLine] = DeformatRecord(
          date: existing.date,
          defMass: existing.defMass + record.defMass,
          iceLine: existing.iceLine,
          iceMass: existing.iceMass + record.iceMass,
          iceName: existing.iceName,
          lineName: existing.lineName,
          defPercent: existing.defPercent + record.defPercent,
        );
      } else {
        grouped[record.iceLine] = record;
      }
    }

    return grouped;
  }

  Future<void> fetchDeformats() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://limo-kpi-e1ab5-default-rtdb.europe-west1.firebasedatabase.app/deformat.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _deformats = [];

        data.forEach((date, dateData) {
          final recordDate = DateTime.parse(date);
          dateData.forEach((_, lineData) {
            lineData.forEach((_, recordData) {
              _deformats.add(DeformatRecord.fromJson(recordData, recordDate));
            });
          });
        });

        _error = '';
      } else {
        _error = 'Failed to load data';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
