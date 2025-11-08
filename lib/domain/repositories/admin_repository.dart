abstract class AdminRepository {
  Future<void> suspendSubscription(String subscriptionId);
  Future<void> reactivateSubscription(String subscriptionId);
  Future<String> sendPaymentLink(String priceId, String userId);
}
