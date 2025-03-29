import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:ui'; // For glass effect

class PaymentHistoryCard extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const PaymentHistoryCard({Key? key, required this.transaction}) : super(key: key);

  @override
  _PaymentHistoryCardState createState() => _PaymentHistoryCardState();
}

class _PaymentHistoryCardState extends State<PaymentHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Enhanced animations for smoother transitions
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final membershipPackage = transaction['membershipPackage'];
    final transactionDate = DateTime.parse(transaction['transactionDate']);
    final formattedDate = DateFormat('MMM dd, yyyy – HH:mm').format(transactionDate);
    final isSuccess = transaction['status'] == 'success';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                transform: Matrix4.identity()
                  ..translate(_isHovered ? 0.0 : 0.0, _isHovered ? -5.0 : 0.0),
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Background with glass effect
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSuccess
                                  ? [
                                Colors.blue.withOpacity(0.1),
                                Colors.teal.withOpacity(0.08),
                              ]
                                  : [
                                Colors.red.withOpacity(0.1),
                                Colors.orange.withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSuccess
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Package Name with Icon
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSuccess
                                              ? Colors.blue.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.card_membership,
                                          color: isSuccess
                                              ? Colors.blue.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          membershipPackage['membershipPackageName'],
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSuccess
                                                ? Colors.blue.shade900
                                                : Colors.red.shade900,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSuccess
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isSuccess
                                              ? Colors.green.shade400
                                              : Colors.red.shade400,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        transaction['status'].toUpperCase(),
                                        style: TextStyle(
                                          color: isSuccess
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Transaction Details with modern layout
                            Row(
                              children: [
                                // Amount Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AMOUNT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${transaction['amount']}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSuccess
                                              ? Colors.blue.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Date Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DATE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Permissions Section with modern style
                            Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                expansionTileTheme: ExpansionTileThemeData(
                                  backgroundColor: Colors.transparent,
                                  collapsedBackgroundColor: Colors.transparent,
                                  tilePadding: EdgeInsets.zero,
                                ),
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: false,
                                childrenPadding: const EdgeInsets.only(top: 8),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSuccess
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.verified_user_outlined,
                                        size: 16,
                                        color: isSuccess
                                            ? Colors.blue.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Permissions',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSuccess
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        membershipPackage['permissions'].length.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSuccess
                                              ? Colors.blue.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSuccess
                                        ? Colors.blue.withOpacity(0.05)
                                        : Colors.red.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: isSuccess
                                        ? Colors.blue.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                children: membershipPackage['permissions'].map<Widget>((permission) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSuccess
                                            ? Colors.blue.withOpacity(0.03)
                                            : Colors.red.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSuccess
                                              ? Colors.blue.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isSuccess
                                                  ? Colors.blue.withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: isSuccess
                                                  ? Colors.blue.shade700
                                                  : Colors.red.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  permission['permissionName'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  permission['description'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}