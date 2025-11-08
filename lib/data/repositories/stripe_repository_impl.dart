import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lavajato/domain/repositories/stripe_repository.dart';

class StripeRepositoryImpl implements StripeRepository {
  final String _cloudFunctionUrl = dotenv.env['STRIPE_DASHBOARD_METRICS_URL']!;

  @override
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      final response = await http.get(Uri.parse(_cloudFunctionUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard metrics');
      }
    } catch (e) {
      print('Error fetching Stripe metrics: $e');
      rethrow;
    }
  }
}
