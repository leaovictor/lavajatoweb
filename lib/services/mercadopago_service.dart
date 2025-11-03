import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lavajato/mercadopago_keys.dart';

class MercadoPagoService {
  Future<Map<String, dynamic>> createPreference(String plan) async {
    final url = Uri.parse('https://api.mercadopago.com/checkout/preferences');

    final Map<String, double> prices = {
      'basic': 29.90,
      'premium': 59.90,
    };
    final price = prices[plan];
    if (price == null) throw Exception('Invalid plan');

    final body = {
      "items": [
        {
          "title": "Assinatura ${plan == 'basic' ? 'Básica' : 'Premium'}",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": price,
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
      // Para ambiente de sandbox, use a URL 'sandbox_init_point'
      final checkoutUrl = responseBody['sandbox_init_point'];
      if (checkoutUrl == null) {
        throw Exception('sandbox_init_point not found in Mercado Pago response');
      }
      return {'checkoutUrl': checkoutUrl};
    } else {
      throw Exception('Failed to create Mercado Pago preference: ${response.body}');
    }
  }
}
