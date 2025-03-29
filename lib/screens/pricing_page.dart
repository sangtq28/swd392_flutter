import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/membership/membership_subscript.dart';
import 'package:flutter_swd392/models/membership/mempackage_model.dart';
import 'package:flutter_swd392/repository/packages_repository.dart';
import 'package:flutter_swd392/repository/user_repository.dart';
import 'package:flutter_swd392/screens/current_package_screen.dart';
import 'package:get/get.dart';
import '../widgets/pricing_card.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  static const int _selectedIndex = 3; // Index của Profile
  final PackageRepository _packageRepository = PackageRepository();
  List<MembershipPackageModel> pricingPlans = [];
  String? errorMessage;
  MembershipSubscriptionModel? currentPackage;

  @override
  void initState() {
    super.initState();
    fetchPricingPlans();
  }
  Future<void> getCurrentPackage() async {
      currentPackage = await UserRepository().getCurrentPackage();
  }

  Future<void> fetchPricingPlans() async {
    try {
      final response = await _packageRepository.getMembershipPackage();
      if (response.status?.toLowerCase() == "successful" && (response.data ?? []).isNotEmpty) {
        setState(() {
          pricingPlans = response.data!;
        });
      } else {
        setState(() {
          errorMessage = response.message ?? "Unknown error occurred";
        });
      }
    } catch (e) {
      print("Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e"))
      );
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền nhẹ nhàng
      appBar: AppBar(
        backgroundColor: Colors.blue[700], // Màu chủ đạo blue
        elevation: 0,
        title: const Text(
          'Pricing Plans',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),  // Replace Navigator with Get.back()
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Flexible(
              child: pricingPlans.isEmpty
                  ? Center(
                child: CircularProgressIndicator(color: Colors.blue[700]),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: pricingPlans
                      .where((plan) => plan.name != "Basic") // Lọc bỏ gói Basic
                      .map((plan) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: PricingCard(plan: plan),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
