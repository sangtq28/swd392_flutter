class GrowthIndicatorModel {
  final int growthIndicatorsId;
  final double height;
  final double weight;
  final double bmi;
  final int childrenId;
  final DateTime recordTime;

  GrowthIndicatorModel({
    required this.growthIndicatorsId,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.childrenId,
    required this.recordTime,
  });

  // Chuyển từ JSON sang GrowthIndicatorModel
  factory GrowthIndicatorModel.fromJson(Map<String, dynamic> json) {
    return GrowthIndicatorModel(
      growthIndicatorsId: json["growthIndicatorsId"],
      height: (json["height"] as num).toDouble(),
      weight: (json["weight"] as num).toDouble(),
      bmi: (json["bmi"] as num).toDouble(),
      childrenId: json["childrenId"],
      recordTime: DateTime.parse((json["recordTime"])), // Chuyển đổi ngày
    );
  }

  // Chuyển từ GrowthIndicatorModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      "growthIndicatorsId": growthIndicatorsId,
      "height": height,
      "weight": weight,
      "bmi": bmi,
      "childrenId": childrenId,
      "recordTime": "${recordTime.day}/${recordTime.month}/${recordTime.year}",
    };
  }

}
