import 'mempackage_model.dart';

class MembershipSubscriptionModel {
  final String startDate;
  final String endDate;
  final String status;
  final MembershipPackageModel? package;

  MembershipSubscriptionModel({
    required this.startDate,
    required this.endDate,
    required this.status,
    this.package,
  });

  factory MembershipSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MembershipSubscriptionModel(
      startDate: json['startDate']?.toString() ?? "",
      endDate: json['endDate']?.toString() ?? "",
      status: json['status']?.toString() ?? "unknown",
      package: json['membershipPackage'] != null
          ? MembershipPackageModel.fromJson(json['membershipPackage'])
          : null, // Kiểm tra null trước khi parse
    );
  }
}
