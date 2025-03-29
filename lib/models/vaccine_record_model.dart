class VaccineRecordModel {
  final int? id;
  final int? childId;
  final int? vaccineId;
  final String? administeredDate;
  final int? dose;
  final String? nextDoseDate;
  final String? childName;
  final String? vaccineName;

  VaccineRecordModel({
    this.id,
    this.childId,
    this.vaccineId,
    this.administeredDate,
    this.dose,
    this.nextDoseDate,
    this.childName,
    this.vaccineName,
  });

  factory VaccineRecordModel.fromJson(Map<String, dynamic> json) {
    return VaccineRecordModel(
      id: json['id'],
      childId: json['childId'],
      vaccineId: json['vaccineId'],
      administeredDate: json['administeredDate'],
      dose: json['dose'],
      nextDoseDate: json['nextDoseDate'],
      childName: json['childName'],
      vaccineName: json['vaccineName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'vaccineId': vaccineId,
      'administeredDate': administeredDate,
      'dose': dose,
      'nextDoseDate': nextDoseDate,
      'childName': childName,
      'vaccineName': vaccineName,
    };
  }
}