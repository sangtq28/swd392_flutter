import 'package:flutter/material.dart';

import '../models/mempackage_model.dart';

class PricingCard extends StatelessWidget {
  final MembershipPackageModel plan; // Use the correct type instead of dynamic

  const PricingCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getPlanIcon(plan.name),
          const SizedBox(height: 8),
          Text(
            plan.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${plan.price}${plan.price > 0 ? ' /mo' : ''}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const SizedBox(height: 16),
          ...plan.permissions.map<Widget>((permission) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.purple, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    permission.description, // Use dot notation
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _getPlanIcon(String planName) {
    switch (planName) {
      case 'Basic':
        return const Icon(Icons.airplanemode_active, color: Colors.blueAccent, size: 40);
      case 'Standard':
        return const Icon(Icons.flight, color: Colors.blueAccent, size: 40);
      case 'Premium':
        return const Icon(Icons.rocket, color: Colors.blueAccent, size: 40);
      default:
        return const Icon(Icons.info, color: Colors.blueAccent, size: 40);
    }
  }
}
