import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    bool isAdmin = false,
  }) : super(
          id: id,
          email: email,
          name: name,
          photoUrl: photoUrl,
          isAdmin: isAdmin,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'],
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
    };
  }
}
