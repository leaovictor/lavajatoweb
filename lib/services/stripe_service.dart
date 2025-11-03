import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // TODO: Replace with your actual Stripe publishable key
  static const String publishableKey = "pk_test_51...YOUR_KEY";

  Future<void> createCheckoutSessionAndRedirect({
    required String planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      final HttpsCallable callable = _functions.httpsCallable('createCheckoutSession');
      final response = await callable.call<Map<String, dynamic>>({
        'planId': planId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      });

      final sessionId = response.data?['sessionId'] as String?;

      if (sessionId == null) {
        throw Exception('The cloud function did not return a session ID.');
      }

      await redirectToCheckout(
        context: null, // This is not needed when using web checkout
        sessionId: sessionId,
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Server Error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
