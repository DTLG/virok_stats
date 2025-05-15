import '../../domain/entities/failure_record.dart';
import '../../domain/repositories/failure_repository.dart';
import '../datasources/failure_remote_data_source.dart';

class FailureRepositoryImpl implements FailureRepository {
  final FailureRemoteDataSource remoteDataSource;

  FailureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FailureRecord>> getFailures() async {
    try {
      final failures = await remoteDataSource.getFailures();
      return failures;
    } catch (e) {
      throw Exception('Failed to load failures: $e');
    }
  }
}
