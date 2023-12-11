class StatisticalData {
  final DateTime date;
  final double doanhThu; // Thay đổi kiểu dữ liệu sang double nếu cần
  final double loiNhuan; // Thay đổi kiểu dữ liệu sang double nếu cần

  StatisticalData(
      {required this.date, required this.doanhThu, required this.loiNhuan});

  factory StatisticalData.fromJson(Map<String, dynamic> json) {
    return StatisticalData(
      date: DateTime.parse(json['date']),
      doanhThu: json['doanhThu'].toDouble(), // Chuyển đổi sang double
      loiNhuan: json['loiNhuan'].toDouble(), // Chuyển đổi sang double
    );
  }
}
