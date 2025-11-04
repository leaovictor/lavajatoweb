import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
    String? phone,
    String? address,
  }) : super(
          id: id,
          name: name,
          email: email,
          photoUrl: photoUrl,
          phone: phone,
          address: address,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      address: data['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'address': address,
    };
  }
}
