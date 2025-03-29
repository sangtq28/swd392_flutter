class VaccineModel {
  final int id;
  final String name;
  final String description;
  final int dosesRequired;

  VaccineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dosesRequired,
  });

  // Chuyển từ JSON thành đối tượng VaccineModel
  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dosesRequired: json['dosesRequired'],
    );
  }

  // Chuyển từ đối tượng VaccineModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosesRequired': dosesRequired,
    };
  }
}
