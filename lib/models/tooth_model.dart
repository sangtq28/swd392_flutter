class ToothModel {
  final int id;
  final int numberOfTeeth;
  final int teethingPeriod;
  final String name;

  ToothModel({
    required this.id,
    required this.numberOfTeeth,
    required this.teethingPeriod,
    required this.name,
  });

  // Chuyển từ JSON sang model
  factory ToothModel.fromJson(Map<String, dynamic> json) {
    return ToothModel(
      id: json['id'] ?? 0,
      numberOfTeeth: json['numberOfTeeth'] ?? 0,
      teethingPeriod: json['teethingPeriod'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  // Chuyển từ model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numberOfTeeth': numberOfTeeth,
      'teethingPeriod': teethingPeriod,
      'name': name,
    };
  }
}
