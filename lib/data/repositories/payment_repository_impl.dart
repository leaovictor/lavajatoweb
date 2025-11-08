import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/payment_model.dart';
import 'package:lavajato/domain/entities/payment_entity.dart';
import 'package:lavajato/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepositoryImpl(this._firestore);

  @override
  Future<List<PaymentEntity>> getPaymentHistory(String userId) async {
    final querySnapshot = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList();
  }
}
