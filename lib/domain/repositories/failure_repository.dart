import '../entities/failure_record.dart';

abstract class FailureRepository {
  Future<List<FailureRecord>> getFailures();
}
