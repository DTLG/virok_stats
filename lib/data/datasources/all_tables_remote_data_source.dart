import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/table_analysis.dart';

abstract class AllTablesRemoteDataSource {
  Future<Map<String, List<TableAnalysis>>> getAllTables();
}

class AllTablesRemoteDataSourceImpl implements AllTablesRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://virok-wms-2a767-default-rtdb.europe-west1.firebasedatabase.app';

  AllTablesRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, List<TableAnalysis>>> getAllTables() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, List<TableAnalysis>> result = {};

        data.forEach((factory, dates) {
          if (dates is Map) {
            final List<TableAnalysis> factoryData = [];
            dates.forEach((date, tables) {
              if (tables is Map) {
                final List<TableData> tablesList = [];
                tables.forEach((tableName, tableData) {
                  if (tableData is Map) {
                    tablesList.add(TableData.fromJson(
                      tableName.toString(),
                      tableData as Map<String, dynamic>,
                    ));
                  }
                });

                factoryData.add(TableAnalysis(
                  factory: factory,
                  date: date,
                  tables: tablesList,
                ));
              }
            });
            result[factory] = factoryData;
          }
        });

        return result;
      } else {
        throw Exception('Failed to load table data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching table analysis data: $e');
      return {};
    }
  }
}
