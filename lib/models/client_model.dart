import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? subscriptionStatus;
  final String rule;

  Client({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.subscriptionStatus,
    this.rule = 'usuario',
  });

  factory Client.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Client(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      subscriptionStatus: data['subscriptionStatus'],
      rule: data['rule'] ?? 'usuario',
    );
  }
}
