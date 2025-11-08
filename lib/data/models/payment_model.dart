import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.date,
    required super.status,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'],
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'date': date,
      'status': status,
    };
  }
}
