import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/order_reserve.dart';

abstract class OrderReserveRemoteDataSource {
  Future<Map<String, OrderReserve>> getOrderReserve();
}

class OrderReserveRemoteDataSourceImpl implements OrderReserveRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://virok-wms-2a767-default-rtdb.europe-west1.firebasedatabase.app';

  OrderReserveRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, OrderReserve>> getOrderReserve() async {
    final response = await client.get(Uri.parse('$baseUrl/order_reserve.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final Map<String, OrderReserve> result = {};

      jsonData.forEach((factory, reserveData) {
        result[factory] =
            OrderReserve.fromJson(reserveData as Map<String, dynamic>);
      });

      return result;
    } else {
      throw Exception('Failed to load order reserve data');
    }
  }
}
