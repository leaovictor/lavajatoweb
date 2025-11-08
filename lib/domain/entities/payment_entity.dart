import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String status;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [id, userId, amount, date, status];
}
