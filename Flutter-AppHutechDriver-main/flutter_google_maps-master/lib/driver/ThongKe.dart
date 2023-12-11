import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/StatisticalData.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbols.dart';

String formatDate(DateTime dateTime) {
  // Sử dụng dấu / thay vì -
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

class ThongKe extends StatefulWidget {
  @override
  _ThongKeState createState() => _ThongKeState();
}

class _ThongKeState extends State<ThongKe> {
  String fromDate = "01/12/2023";
  String toDate = "30/12/2023";
  late Future<List<StatisticalData>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchStatisticalData(fromDate, toDate);
  }

  String formatDate(DateTime dateTime) {
    // Chọn một định dạng phù hợp mà server của bạn chấp nhận

    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString()}";
  }

  Future<List<StatisticalData>> fetchStatisticalData(
      String fromDate, String toDate) async {
    String queryString = Uri(queryParameters: {
      'fromDate': fromDate,
      'toDate': toDate,
    }).query;

    var uri = Uri.parse(
        'https://10.0.2.2:7238/api/Statistical/GetStatistical?$queryString');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body)['data'];
      return jsonData.map((item) => StatisticalData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load statistical data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StatisticalData>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Tạo danh sách các BarChartGroupData từ dữ liệu
          List<BarChartGroupData> barGroups = snapshot.data!
              .map((data) => BarChartGroupData(
                    x: data.date
                        .day, // Sử dụng ngày hoặc một chỉ số khác làm trục X
                    barRods: [
                      BarChartRodData(
                        y: data.loiNhuan.toDouble(), // Giá trị cho mỗi cột
                        colors: [Colors.blue], // Màu sắc của cột
                        borderRadius:
                            BorderRadius.circular(4), // Bo tròn các góc nếu cần
                      ),
                    ],
                  ))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Thống Kê Lợi Nhuận'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: false, // Tắt hoặc bật tương tác nếu cần
                  ),
                  titlesData: FlTitlesData(
                    // Cấu hình cho các trục
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                      margin: 16,
                      getTitles: (double value) {
                        // Cấu hình các nhãn trên trục X
                        return DateFormat('dd/MM').format(
                          DateTime(2023, 12, value.toInt()),
                        );
                      },
                    ),
                    leftTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}
