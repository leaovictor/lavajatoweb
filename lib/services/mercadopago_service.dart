import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lavajato/mercadopago_keys.dart';

import 'package:lavajato/services/plan_service.dart';
// ... (rest of your imports)

class MercadoPagoService {
  final PlanService _planService = PlanService();

  Future<Map<String, dynamic>> createPreference(String planName, String userId) async {
    final url = Uri.parse('https://api.mercadopago.com/checkout/preferences');

    final plan = await _planService.getPlanByName(planName);
    if (plan == null) throw Exception('Invalid plan');

    final body = {
      "items": [
        {
          "title": "Assinatura ${plan.name}",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": plan.price,
        }
      ],
      "payer": {
        "email": FirebaseAuth.instance.currentUser?.email ?? '',
      },
      "back_urls": {
        "success": "https://www.success.com",
        "failure": "https://www.failure.com",
        "pending": "https://www.pending.com",
      },
      "auto_return": "approved",
      "external_reference": userId,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $mercadoPagoAccessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final checkoutUrl = responseBody['init_point'];
      if (checkoutUrl == null) {
        throw Exception('init_point not found in Mercado Pago response');
      }
      return {'checkoutUrl': checkoutUrl};
    } else {
      throw Exception('Failed to create Mercado Pago preference: ${response.body}');
    }
  }
}
