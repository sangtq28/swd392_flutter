class MembershipPackageModel {
  final int id;
  final String name;
  final double price;
  final String image;
  final bool isActive;
  final List<Permission> permissions;

  MembershipPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.isActive,
    required this.permissions,
  });

  factory MembershipPackageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MembershipPackageModel(
        id: 0,
        name: "Unknown",
        price: 0,
        image: "",
        isActive: false,
        permissions: [],
      );
    }
    return MembershipPackageModel(
      id: json['membershipPackageId'], // Đảm bảo tên key đúng
      name: json['membershipPackageName'], // Đúng key từ API
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? "",
      isActive: json['isActive'] ?? false,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
          .map((e) => Permission.fromJson(e))
          .toList()
          : [],
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

