import 'package:flutter/material.dart';
import 'package:flutter_swd392/models/mempackage_model.dart';
import 'package:flutter_swd392/repository/packages_repository.dart';
import '../widgets/pricing_card.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({Key? key}) : super(key: key);

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final PackageRepository _packageRepository = PackageRepository();
  List<MembershipPackageModel> pricingPlans = [];
  String? errorMessage; // Biến để hiển thị lỗi nếu có

  @override
  void initState() {
    super.initState();
    fetchPricingPlans();
  }

  Future<void> fetchPricingPlans() async {
    try {
      final response = await _packageRepository.getMembershipPackage();

      print("Raw API Response: ${response.toJson((data) => data)}");

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
      appBar: AppBar(
        title: const Text('Pricing Plans'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Tailored pricing plans designed for you',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'All plans include 10+ advanced tools and features. Choose the best plan to fit your needs.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: pricingPlans.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: 0,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: pricingPlans
                          .map((plan) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 300,
                          child: PricingCard(plan: plan),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
