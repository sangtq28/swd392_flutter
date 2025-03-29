class VaccineScheduleModel {
  final int id;
  final int vaccineId;
  final int recommendedAgeMonths;
  final String? vaccineName;
  final int doseNumber;

  VaccineScheduleModel({
    required this.id,
    required this.vaccineId,
    required this.recommendedAgeMonths,
    this.vaccineName,
    required this.doseNumber,
  });

  factory VaccineScheduleModel.fromJson(Map<String, dynamic> json) {
    return VaccineScheduleModel(
      id: json['id'] ?? 0,
      vaccineId: json['vaccineId'] ?? 0,
      recommendedAgeMonths: json['recommendedAgeMonths'] ?? 0,
      vaccineName: json['vaccineName'],
      doseNumber: json['doseNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineId': vaccineId,
      'recommendedAgeMonths': recommendedAgeMonths,
      'vaccineName': vaccineName,
      'doseNumber': doseNumber,
    };
  }
}