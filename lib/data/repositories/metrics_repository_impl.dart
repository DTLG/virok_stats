import '../../domain/entities/metric.dart';
import '../../domain/repositories/metrics_repository.dart';
import '../datasources/metrics_remote_data_source.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  final MetricsRemoteDataSource remoteDataSource;

  MetricsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Metric>> getMetrics() async {
    try {
      final metrics = await remoteDataSource.getMetrics();
      return metrics;
    } catch (e) {
      throw Exception('Failed to load metrics: $e');
    }
  }
}
