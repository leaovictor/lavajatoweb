import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lavajato/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final String _baseUrl = dotenv.env['FIREBASE_FUNCTIONS_BASE_URL']!;

  @override
  Future<void> suspendSubscription(String subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/suspendSubscription'),
        body: json.encode({'subscriptionId': subscriptionId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to suspend subscription');
      }
    } catch (e) {
      print('Error suspending subscription: $e');
      rethrow;
    }
  }

  @override
  Future<void> reactivateSubscription(String subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reactivateSubscription'),
        body: json.encode({'subscriptionId': subscriptionId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reactivate subscription');
      }
    } catch (e) {
      print('Error reactivating subscription: $e');
      rethrow;
    }
  }

  @override
  Future<String> sendPaymentLink(String priceId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendPaymentLink'),
        body: json.encode({'priceId': priceId, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['id'];
      } else {
        throw Exception('Failed to send payment link');
      }
    } catch (e) {
      print('Error sending payment link: $e');
      rethrow;
    }
  }
}
