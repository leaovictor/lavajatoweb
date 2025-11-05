import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SubscriptionService {
  // TODO: Replace with your actual Cloud Function URL
  final String _cloudFunctionUrl = 'https://us-central1-lavajato-5944c.cloudfunctions.net/createSubscriptionCheckoutSession';

  Future<String?> createCheckoutSession({
    required String priceId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'priceId': priceId,
          'userId': userId,
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
