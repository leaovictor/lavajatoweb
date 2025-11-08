import 'package:lavajato/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPaymentHistory(String userId);
}
