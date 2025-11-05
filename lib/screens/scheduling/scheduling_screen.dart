import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/service_model.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulingScreen extends StatefulWidget {
  final Service service;

  const SchedulingScreen({super.key, required this.service});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final AuthRepository _authRepository;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  CarEntity? _selectedCar;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _authRepository = Provider.of<AuthRepository>(context, listen: false);
  }

  Future<void> _confirmBooking() async {
    if (_selectedDay == null || _selectedTime == null || _selectedCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione data, hora e veículo.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para agendar.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final startTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final endTime = startTime.add(Duration(minutes: widget.service.duration));

    final appointment = Appointment(
      id: '', // Firestore will generate this
      userId: user.uid,
      serviceId: widget.service.id,
      serviceName: widget.service.name,
      startTime: startTime,
      endTime: endTime,
      carId: _selectedCar!.id,
      carInfo: '${_selectedCar!.brand} ${_selectedCar!.model} - ${_selectedCar!.licensePlate}',
    );

    try {
      await _firestoreService.addAppointment(appointment.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento confirmado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar agendamento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

   List<TimeOfDay> _generateAvailableTimeSlots(
      List<Appointment> bookedAppointments) {
    final List<TimeOfDay> availableSlots = [];

    const int openingHour = 8;
    const int closingHour = 18;
    const int lunchStart = 12;
    const int lunchEnd = 13;
    final int serviceDuration = widget.service.duration;

    DateTime potentialSlot = DateTime(
        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day, openingHour);

    while (potentialSlot.hour < closingHour) {
      final potentialSlotTimeOfDay = TimeOfDay.fromDateTime(potentialSlot);

      if (potentialSlotTimeOfDay.hour >= lunchStart &&
          potentialSlotTimeOfDay.hour < lunchEnd) {
        potentialSlot = potentialSlot.add(const Duration(minutes: 30));
        continue;
      }

      final potentialSlotEnd =
          potentialSlot.add(Duration(minutes: serviceDuration));

      bool hasConflict = false;
      for (final booked in bookedAppointments) {
        if (potentialSlot.isBefore(booked.endTime) &&
            potentialSlotEnd.isAfter(booked.startTime)) {
          hasConflict = true;
          break;
        }
      }

      if (!hasConflict &&
          (potentialSlotEnd.hour < closingHour ||
              (potentialSlotEnd.hour == closingHour &&
                  potentialSlotEnd.minute == 0))) {
        availableSlots.add(potentialSlotTimeOfDay);
      }

      potentialSlot = potentialSlot.add(const Duration(minutes: 30));
    }

    return availableSlots;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar ${widget.service.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TableCalendar(
                    locale: 'pt_BR',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 60)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTime = null;
                      });
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selecione um Veículo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<CarEntity>>(
                    stream: user != null ? _authRepository.getCars(user.uid) : Stream.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nenhum veículo cadastrado. Adicione um no seu perfil.');
                      }
                      final cars = snapshot.data!;
                      return DropdownButtonFormField<CarEntity>(
                        value: _selectedCar,
                        hint: const Text('Escolha um veículo'),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: cars.map((car) {
                          return DropdownMenuItem(
                            value: car,
                            child: Text('${car.brand} ${car.model} (${car.licensePlate})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCar = value;
                          });
                        },
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Horários Disponíveis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100, // Adjust height as needed
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getAppointmentsForDay(_selectedDay!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Erro ao carregar horários.'));
                        }

                        final bookedAppointments = snapshot.data?.docs
                                .map((doc) => Appointment.fromFirestore(doc))
                                .toList() ??
                            [];

                        final availableSlots =
                            _generateAvailableTimeSlots(bookedAppointments);

                        if (availableSlots.isEmpty) {
                          return const Center(
                              child: Text(
                                  'Nenhum horário disponível para este dia.'));
                        }

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: availableSlots.length,
                          itemBuilder: (context, index) {
                            final time = availableSlots[index];
                            final isSelected = _selectedTime == time;
                            return ChoiceChip(
                              label: Text(time.format(context)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTime = selected ? time : null;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedTime == null || _selectedCar == null ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Confirmar Agendamento'),
                  ),
                ],
              ),
            ),
    );
  }
}
