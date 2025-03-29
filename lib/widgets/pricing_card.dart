import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/membership/membership_subscript.dart';
import '../models/membership/mempackage_model.dart';
import '../repository/user_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage.service.dart';

class PricingCard extends StatefulWidget {
  const PricingCard({
    super.key,
    required this.plan,
    this.isRecommended = false
  });

  final MembershipPackageModel plan;
  final bool isRecommended;

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  MembershipSubscriptionModel? _currentSubscription;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadCurrentPackage();
  }

  Future<void> _loadCurrentPackage() async {
    try {
      final response = await UserRepository().getCurrentPackage();
      setState(() {
        _currentSubscription = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading current package: $e');
    }
  }

  bool get isCurrentPlan {
    if (_currentSubscription == null) return false;
    return _currentSubscription!.package?.id == widget.plan.id;
  }

  @override
  Widget build(BuildContext context) {
    // 2025 modern color gradients
    final LinearGradient baseGradient = LinearGradient(
      colors: [
        Color(0xFFF5F7FA),
        Color(0xFFE4E7EB),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final LinearGradient primaryGradient = LinearGradient(
      colors: [
        Color(0xFF6B46C1), // Purple
        Color(0xFF4C51BF), // Blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 380, // Slightly wider card
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow effect for recommended plan
          if (widget.isRecommended)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6B46C1).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

          // Main card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: widget.isRecommended ? primaryGradient : baseGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isRecommended ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isRecommended
                      ? Color(0xFF6B46C1).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan icon and name row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: widget.isRecommended
                            ? LinearGradient(
                          colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: widget.isRecommended ? null : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!widget.isRecommended)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: _getPlanIcon(widget.plan.name, widget.isRecommended),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plan.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: widget.isRecommended ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perfect for ${_getTargetDescription(widget.plan.name)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isRecommended ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Price section with billing toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Monthly Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isRecommended ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Spacer(),
                        // Billing toggle - using dummy toggle since we can't store state
                        Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: widget.isRecommended ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.isRecommended ? Colors.white.withOpacity(0.2) : Color(0xFF6B46C1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Monthly',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isRecommended ? Colors.white : Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Text(
                                  'Yearly',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isRecommended ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.plan.price}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: widget.isRecommended ? Colors.white : Color(0xFF6B46C1),
                          ),
                        ),
                        if (widget.plan.price > 0)
                          Text(
                            '/mo',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isRecommended ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        // Free trial badge - conditionally shown for premium plans
                        if (widget.plan.price > 0 && widget.plan.name.toLowerCase() != 'basic')
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.isRecommended ? Colors.white.withOpacity(0.2) : Color(0xFFE6FFFA),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '14-day free trial',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: widget.isRecommended ? Colors.white : Color(0xFF0D9488),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // We'll determine user count based on plan level
                    if (widget.plan.name.toLowerCase() != 'basic')
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Up to ${widget.plan.name.toLowerCase() == 'premium' ? '50' : '10'} users',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isRecommended ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Usage indicators (based on plan tier)
                if (widget.plan.name.toLowerCase() != 'basic')
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isRecommended ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildUsageIndicator(
                        //   'Storage',
                        //   widget.plan.name.toLowerCase() == 'premium' ? '100GB' : '20GB',
                        //   Icons.storage_rounded,
                        //   widget.isRecommended,
                        // ),
                        SizedBox(height: 12),
                        // _buildUsageIndicator(
                        //   'Requests',
                        //   widget.plan.name.toLowerCase() == 'premium' ? 'Unlimited' : '10K/mo',
                        //   Icons.sync_alt_rounded,
                        //   widget.isRecommended,
                        // ),
                      ],
                    ),
                  ),

                // Features
                Row(
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isRecommended ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isRecommended ? Colors.white.withOpacity(0.2) : Color(0xFFE9D8FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.plan.permissions.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.isRecommended ? Colors.white : Color(0xFF6B46C1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Features list in scrollable container
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 150,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: widget.plan.permissions.asMap().entries.map<Widget>((entry) {
                        final index = entry.key;
                        final permission = entry.value;
                        final isPremium = index < 2; // Just for demo, first 2 features are premium

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.isRecommended ? Colors.white.withOpacity(0.2) :
                                  isPremium ? Color(0xFFFEF3C7) : Color(0xFFECFDFF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  isPremium ? Icons.star_rounded : Icons.check,
                                  color: widget.isRecommended ? Colors.white :
                                  isPremium ? Color(0xFFD97706) : Color(0xFF0891B2),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      permission.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isPremium ? FontWeight.w500 : FontWeight.normal,
                                        color: widget.isRecommended ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    // Add some dummy details for the first 3 features
                                    if (index < 3)
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          _getFeatureDetail(index),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.isRecommended ? Colors.white60 : Colors.black54,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Compare plans button
                    OutlinedButton(
                      onPressed: () {
                        // Show comparison modal
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: widget.isRecommended ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: Text(
                        'Compare',
                        style: TextStyle(
                          color: widget.isRecommended ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Main action button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading || isCurrentPlan
                            ? null
                            : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          // Use the ID from the current plan card that the user clicked
                          int upgradePackageId = widget.plan.id;

                          try {
                            final userToken = await StorageService.getAuthData();
                            final token = userToken?.token;
                            if (userToken == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Vui lòng đăng nhập để nâng cấp gói")),
                              );
                              return;
                            }

                            print("Upgrading to package ID: $upgradePackageId");
                            print(token);

                            final response = await ApiService.upgradeMembershipPackage(
                              token!,
                              upgradePackageId,
                              "monthly",
                            );

                            // Rest of your code stays the same
                            print(response.body);

                            if (response.statusCode == 200) {
                              final responseData = jsonDecode(response.body);
                              final paypalUrl = responseData['link']; // Lấy link PayPal từ response

                              if (paypalUrl != null) {
                                // Mở trình duyệt hoặc WebView với PayPal URL
                                if (await canLaunchUrl(Uri.parse(paypalUrl))) {
                                  await launchUrl(Uri.parse(paypalUrl), mode: LaunchMode.externalApplication);
                                } else {
                                  throw "Không thể mở PayPal";
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Lỗi: Không tìm thấy link PayPal")),
                                );
                              }
                            } else {
                              // Xử lý lỗi từ server
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Lỗi: ${response.body}")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lỗi hệ thống: $e")),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentPlan
                              ? Colors.green
                              : widget.isRecommended
                              ? Colors.white
                              : const Color(0xFF6B46C1),
                          foregroundColor: isCurrentPlan
                              ? Colors.white
                              : widget.isRecommended
                              ? const Color(0xFF6B46C1)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: isCurrentPlan ? const Color(0xFFF97316) : Colors.grey.shade300,
                          disabledForegroundColor: isCurrentPlan ? Colors.white : Colors.grey.shade600,
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.isRecommended ? const Color(0xFF6B46C1) : Colors.white,
                          ),
                        )
                            : Text(
                          isCurrentPlan
                              ? 'Current Plan'
                              : widget.plan.price > 0
                              ? 'Upgrade Now'
                              : 'Subscribe',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Payment options - only show for paid plans
                if (widget.plan.price > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPaymentIcon('visa', widget.isRecommended),
                        _buildPaymentIcon('paypal', widget.isRecommended),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0, duration: 600.ms),

          // Recommended badge with subtle animation
          if (widget.isRecommended)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[400]!, Colors.amber[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'RECOMMENDED',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scaleXY(
                begin: 1.0,
                end: 1.05,
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for UI elements
  Widget _buildUsageIndicator(String label, String value, IconData icon, bool isRecommended) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isRecommended ? Colors.white.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isRecommended ? Colors.white70 : Color(0xFF6B46C1),
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isRecommended ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isRecommended ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentIcon(String provider, bool isRecommended) {
    Map<String, IconData> paymentIcons = {
      'visa': Icons.credit_card,
      'paypal': Icons.account_balance_wallet_rounded,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isRecommended ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        paymentIcons[provider] ?? Icons.credit_card,
        size: 16,
        color: isRecommended ? Colors.white60 : Colors.black45,
      ),
    );
  }

  // Helper method to get feature details - simulated since we can't add properties
  String _getFeatureDetail(int index) {
    switch (index) {
      case 0:
        return 'Unlimited access to all core features';
      case 1:
        return 'Priority customer support 24/7';
      case 2:
        return 'Advanced analytics and reporting';
      default:
        return '';
    }
  }

  Widget _getPlanIcon(String planName, bool isRecommended) {
    final Color iconColor = isRecommended ? Colors.white : const Color(0xFF6B46C1);

    switch (planName.toLowerCase()) {
      case 'basic':
        return Icon(Icons.stars_rounded, color: iconColor, size: 28);
      case 'standard':
        return Icon(Icons.bolt_rounded, color: iconColor, size: 28);
      case 'premium':
        return Icon(Icons.rocket_launch_rounded, color: iconColor, size: 28);
      default:
        return Icon(Icons.workspace_premium_rounded, color: iconColor, size: 28);
    }
  }

  String _getTargetDescription(String planName) {
    switch (planName.toLowerCase()) {
      case 'basic':
        return 'beginners';
      case 'standard':
        return 'regular users';
      case 'premium':
        return 'advanced needs';
      default:
        return 'all users';
    }
  }
}