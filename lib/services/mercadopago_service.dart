import 'package:firebase_auth/firebase_auth.dart';

class MercadoPagoService {
  // Simulates a backend call to create a payment preference
  Future<Map<String, dynamic>> createPreference(String plan) async {
    // In a real app, this would make an HTTP request to your server.
    // Your server would then use the Mercado Pago SDK with your access token
    // to create the preference and return the checkout URL.

    final Map<String, double> prices = {
      'basic': 29.90,
      'premium': 59.90,
    };
    final price = prices[plan];
    if (price == null) throw Exception('Invalid plan');

    // Simulate the response from your backend
    return Future.delayed(const Duration(seconds: 1), () {
      return {
        "status": "201",
        "response": {
          "id": "123456789-abcdefgh",
          "init_point": "https://www.mercadopago.com.br/sandbox/pay/123456789abcdefgh",
        },
      };
    });
  }
}
