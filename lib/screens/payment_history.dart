import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_swd392/services/storage.service.dart';
import 'package:http/http.dart' as http;

import '../widgets/payment_history_card.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<dynamic> transactions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    final userAuth = await StorageService.getAuthData();
    final token = userAuth?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://swd392-backend-fptu.growplus.hungngblog.com/api/PaymentTransactions/history'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          transactions = jsonResponse['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching payment history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        // Modern 2025 gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F9FF), // Very light blue-white
              Color(0xFFEDF6FF), // Subtle light blue tint
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
            ? const Center(child: Text('No transactions found'))
            : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return PaymentHistoryCard(transaction: transactions[index]);
          },
        ),
      ),
    );
  }
}