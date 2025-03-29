class ChildrenModel {
  final int? id;
  final String fullName;
  final String avatar;
  final String dob;
  final String bloodType;
  final String allergies;
  final String chronicConditions;
  final String gender;

  ChildrenModel({
    this.id,
    required this.fullName,
    required this.avatar,
    required this.dob,
    required this.bloodType,
    required this.allergies,
    required this.chronicConditions,
    required this.gender,
  });

  factory ChildrenModel.fromJson(Map<String, dynamic> json) {
    return ChildrenModel(
      id: json['childrenId'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      dob: json['dob'],
      bloodType: json['bloodType'],
      allergies: json['allergies'],
      chronicConditions: json['chronicConditions'],
      gender: json['gender'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "avatar": avatar,
      "dob": dob,
      "bloodType": bloodType,
      "allergies": allergies,
      "chronicConditions": chronicConditions,
      "gender": gender,
    };
  }
}
