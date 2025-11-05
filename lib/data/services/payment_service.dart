import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PaymentService {
  // TODO: Replace with your actual Cloud Function URL
  final String _cloudFunctionUrl = 'https://us-central1-lavajato-5944c.cloudfunctions.net/createCheckoutSession';

  Future<String?> createCheckoutSession({
    required String serviceName,
    required int price,
    required String userId,
    required Map<String, dynamic> appointmentData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'serviceName': serviceName,
          'price': price,
          'userId': userId,
          'appointmentData': appointmentData,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        debugPrint('Error creating checkout session: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating checkout session: $e');
      return null;
    }
  }
}
