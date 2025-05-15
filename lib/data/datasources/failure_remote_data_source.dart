import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/failure_record_model.dart';

abstract class FailureRemoteDataSource {
  Future<List<FailureRecordModel>> getFailures();
}

class FailureRemoteDataSourceImpl implements FailureRemoteDataSource {
  final http.Client client;

  FailureRemoteDataSourceImpl({required this.client});

  @override
  Future<List<FailureRecordModel>> getFailures() async {
    final response = await client.get(Uri.parse(
        'https://limo-kpi-e1ab5-default-rtdb.europe-west1.firebasedatabase.app/test.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.values
          .map((failure) => FailureRecordModel.fromJson(failure))
          .toList();
    } else {
      throw Exception('Failed to load failures');
    }
  }
}
