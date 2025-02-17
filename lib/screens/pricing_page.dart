import 'package:flutter/material.dart';
import '../widgets/pricing_card.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Pricing Plans'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Horizontal scroll enabled
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // First Pricing Card
            PricingCard(
              planName: 'Basic',
              price: 'Free',
              features: [
                'Allows tracking growth metrics (height, weight)',
                'Provides basic growth charts (BMI, trends)',
                'Access and export data for analysis',
                'Set and track custom milestones for child growth',
              ],
              icon: Icons.space_dashboard_rounded,
              buttonColor: Colors.deepPurple,
            ),

            SizedBox(width: 16),

            // Second Pricing Card
            PricingCard(
              planName: 'Standard',
              price: '\$19.99',
              features: [
                'Allows tracking growth metrics (height, weight)',
                'Provides access to growth charts (BMI, trends)',
                'Share data with doctors or family',
                'Access and export data for analysis',
                'Set and track custom milestones for child growth',
              ],
              icon: Icons.rocket_launch_rounded,
              buttonColor: Colors.blueAccent,
            ),

            SizedBox(width: 16),

            // Third Pricing Card
            PricingCard(
              planName: 'Premium',
              price: '\$49.99',
              features: [
                'Allows tracking growth metrics (height, weight)',
                'Provides access to growth charts (BMI, trends)',
                'Share data with doctors or family',
                'Receive premium alerts & reminders',
                'Access and export data for analysis',
                'Set and track custom milestones for child development',
              ],
              icon: Icons.rocket_rounded,
              buttonColor: Colors.orangeAccent,
            ),
          ],
        ),
      ),
    );
  }
}
