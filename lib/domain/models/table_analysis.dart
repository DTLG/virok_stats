class TableAnalysis {
  final String factory;
  final String date;
  final List<TableData> tables;

  TableAnalysis({
    required this.factory,
    required this.date,
    required this.tables,
  });

  factory TableAnalysis.fromJson(Map<String, dynamic> json) {
    List<TableData> tablesList = [];
    json.forEach((key, value) {
      if (key.startsWith('Стіл')) {
        tablesList.add(TableData.fromJson(key, value));
      }
    });

    return TableAnalysis(
      factory: json['factory'] ?? '',
      date: json['date'] ?? '',
      tables: tablesList,
    );
  }
}

class TableData {
  final String name;
  final int countItems;
  final int countOrder;
  final int countUItems;
  final int queue;

  TableData({
    required this.name,
    required this.countItems,
    required this.countOrder,
    required this.countUItems,
    required this.queue,
  });

  factory TableData.fromJson(String name, Map<String, dynamic> json) {
    return TableData(
      name: name,
      countItems: json['count_items'] ?? 0,
      countOrder: json['count_order'] ?? 0,
      countUItems: json['count_u_items'] ?? 0,
      queue: json['queue'] ?? 0,
    );
  }
}
