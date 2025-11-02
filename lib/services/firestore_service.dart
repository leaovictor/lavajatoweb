import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/client_model.dart';

import 'package:lavajato/models/car_model.dart';
import 'package:lavajato/models/service_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(
      String uid, String name, String email, String phone, {String rule = 'usuario'}) async {
    try {
      await _db.collection('clientes').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'rule': rule,
      });
    } catch (e) {
      print(e);
      // Handle errors appropriately
    }
  }

  Future<void> addService(Service service) async {
    try {
      await _db.collection('servicos').add({
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
      });
    } catch (e) {
      print(e);
      // Handle errors appropriately
      rethrow;
    }
  }

  Future<void> addCar(String uid, Car car) async {
    try {
      await _db.collection('clientes').doc(uid).collection('cars').add(car.toMap());
    } catch (e) {
      print(e);
      // Handle errors appropriately
      rethrow;
    }
  }

  Stream<List<Car>> getCars(String uid) {
    return _db
        .collection('clientes')
        .doc(uid)
        .collection('cars')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList());
  }

  Future<void> deleteCar(String uid, String carId) async {
    try {
      await _db.collection('clientes').doc(uid).collection('cars').doc(carId).delete();
    } catch (e) {
      print(e);
      // Handle errors appropriately
      rethrow;
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      await _db.collection('agendamentos').add(appointment.toMap());
    } catch (e) {
      print(e);
      // Handle errors appropriately
    }
  }

  Stream<List<Appointment>> getAppointmentsForDay(DateTime day) {
    Timestamp startOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day, 23, 59, 59));

    return _db
        .collection('agendamentos')
        .where('data', isGreaterThanOrEqualTo: startOfDay)
        .where('data', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Future<void> updateUserSubscriptionStatus(String uid, String status, String plan) async {
    try {
      await _db.collection('clientes').doc(uid).update({
        'subscriptionStatus': status,
        'subscriptionPlan': plan,
      });
    } catch (e) {
      print(e);
      // Handle errors appropriately
    }
  }

  Stream<Client> getUser(String uid) {
    return _db
        .collection('clientes')
        .doc(uid)
        .snapshots()
        .map((doc) => Client.fromFirestore(doc));
  }

  Stream<List<Appointment>> getMyAppointments(String uid) {
    return _db
        .collection('agendamentos')
        .where('clienteId', isEqualTo: uid)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Stream<QuerySnapshot> getServices() {
    return _db.collection('servicos').snapshots();
  }

  Stream<List<Appointment>> getAllAppointmentsForDay(DateTime day) {
    Timestamp startOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day, 23, 59, 59));

    return _db
        .collection('agendamentos')
        .where('data', isGreaterThanOrEqualTo: startOfDay)
        .where('data', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Stream<List<Client>> getActiveSubscribers() {
    return _db
        .collection('clientes')
        .where('subscriptionStatus', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromFirestore(doc))
            .toList());
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _db.collection('agendamentos').doc(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      print(e);
      // Handle errors appropriately
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _db.collection('agendamentos').doc(appointmentId).update({
        'status': 'cancelado',
      });
    } catch (e) {
      print(e);
      // Handle errors appropriately
    }
  }}
