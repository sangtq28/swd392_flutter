class TeethRecordModel {
  final int childId;
  final int toothId;
  final String eruptionDate;
  final String recordTime;
  final String note;

  TeethRecordModel({
    required this.childId,
    required this.toothId,
    required this.eruptionDate,
    required this.recordTime,
    required this.note,
  });

  factory TeethRecordModel.fromJson(Map<String, dynamic> json) {
    return TeethRecordModel(
      childId: json['childId'] ?? 0,
      toothId: json['toothId'] ?? 0,
      eruptionDate: json['eruptionDate'] ?? '',
      recordTime: json['recordTime'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'toothId': toothId,
      'eruptionDate': eruptionDate,
      'recordTime': recordTime,
      'note': note,
    };
  }
}
