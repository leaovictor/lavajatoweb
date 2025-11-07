import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/data/models/subscription_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    bool isAdmin = false,
    SubscriptionModel? subscription,
  }) : super(
          id: id,
          email: email,
          name: name,
          photoUrl: photoUrl,
          isAdmin: isAdmin,
          subscription: subscription,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      isAdmin: data['isAdmin'] ?? false,
      subscription: data['subscription'] != null
          ? SubscriptionModel.fromMap(data['subscription'])
          : null,
    );
  }
}
