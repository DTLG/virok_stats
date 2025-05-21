import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/order_analysis.dart';

abstract class OrderAnalysisRemoteDataSource {
  Future<Map<String, Map<String, Map<String, OrderAnalysis>>>>
      getOrderAnalysis();
}

class OrderAnalysisRemoteDataSourceImpl
    implements OrderAnalysisRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://virok-wms-2a767-default-rtdb.europe-west1.firebasedatabase.app';

  OrderAnalysisRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, Map<String, Map<String, OrderAnalysis>>>>
      getOrderAnalysis() async {
    final response =
        await client.get(Uri.parse('$baseUrl/order_analysis.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final Map<String, Map<String, Map<String, OrderAnalysis>>> result = {};

      jsonData.forEach((factory, dates) {
        result[factory] = {};
        (dates as Map<String, dynamic>).forEach((date, orders) {
          result[factory]![date] = {};
          (orders as Map<String, dynamic>).forEach((orderId, orderData) {
            result[factory]![date]![orderId] =
                OrderAnalysis.fromJson(orderData);
          });
        });
      });

      return result;
    } else {
      throw Exception('Failed to load order analysis data');
    }
  }
}
