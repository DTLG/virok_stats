import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/metric_model.dart';

abstract class MetricsRemoteDataSource {
  Future<List<MetricModel>> getMetrics();
}

class MetricsRemoteDataSourceImpl implements MetricsRemoteDataSource {
  final http.Client client;

  MetricsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MetricModel>> getMetrics() async {
    final response = await client.get(Uri.parse(
        'https://limo-kpi-e1ab5-default-rtdb.europe-west1.firebasedatabase.app/metrics.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.values.map((metric) => MetricModel.fromJson(metric)).toList();
    } else {
      throw Exception('Failed to load metrics');
    }
  }
}
