class MembershipPackageModel {
  final int id;
  final String name;
  final double price;
  final String status;
  final int validityPeriod;
  final List<Permission> permissions;

  MembershipPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
    required this.validityPeriod,
    required this.permissions,
  });

  factory MembershipPackageModel.fromJson(Map<String, dynamic> json) {

    return MembershipPackageModel(
      id: json['membershipPackageId'] ?? 0,
      name: json['membershipPackageName']?.toString() ?? "Unknown",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? "Unknown",
      validityPeriod: json['validityPeriod'] ?? 0,
      permissions: (json['permissions'] as List?)?.map((e) {
        return Permission.fromJson(e as Map<String, dynamic>);
      }).toList() ?? [],
    );
  }

}




class Permission {
  final int id;
  final String name;
  final String description;

  Permission({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['permissionId'] != null
          ? int.tryParse(json['permissionId'].toString()) ?? 0
          : 0,  //
      name: json['permissionName']?.toString() ?? "Unknown",
      description: json['description']?.toString() ?? "No description",
    );
  }
}

