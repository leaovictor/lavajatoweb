import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/screens/booking/confirmation_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final ServiceEntity service;

  const SelectDateTimeScreen({
    super.key,
    required this.service,
  });

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTimeSlot;

  List<DateTime> _availableTimeSlots = [];
  bool _isLoadingTimes = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableTimesForDay(_selectedDay!);
    });
  }

  Future<void> _loadAvailableTimesForDay(DateTime day) async {
    setState(() {
      _isLoadingTimes = true;
      _availableTimeSlots = [];
      _selectedTimeSlot = null;
    });

    final appointmentRepository =
        Provider.of<AppointmentRepository>(context, listen: false);
    final bookedAppointments =
        await appointmentRepository.getAppointmentsForDay(day);

    final generatedSlots = _generateAvailableTimeSlots(day, bookedAppointments);

    setState(() {
      _availableTimeSlots = generatedSlots;
      _isLoadingTimes = false;
    });
  }

  List<DateTime> _generateAvailableTimeSlots(
      DateTime day, List<AppointmentEntity> bookedAppointments) {

    // Define business hours (e.g., 9 AM to 5 PM)
    final startTime = DateTime(day.year, day.month, day.day, 9, 0);
    final endTime = DateTime(day.year, day.month, day.day, 17, 0);
    final serviceDuration = Duration(minutes: widget.service.durationInMinutes);

    final List<DateTime> slots = [];
    var currentTime = startTime;

    while (currentTime.add(serviceDuration).isBefore(endTime) ||
           currentTime.add(serviceDuration).isAtSameMomentAs(endTime)) {

      bool isSlotBooked = bookedAppointments.any((appointment) {
        final appointmentStart = appointment.startTime;
        final appointmentEnd = appointment.endTime;

        // Check for overlap
        return (currentTime.isBefore(appointmentEnd) &&
                currentTime.add(serviceDuration).isAfter(appointmentStart));
      });

      if (!isSlotBooked) {
        slots.add(currentTime);
      }

      // Move to the next potential slot (e.g., every 30 minutes)
      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione Data e Hora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadAvailableTimesForDay(selectedDay);
                }
              },
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Horários Disponíveis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Time Slots
            Expanded(
              child: _isLoadingTimes
                  ? const Center(child: CircularProgressIndicator())
                  : _availableTimeSlots.isEmpty
                      ? const Center(child: Text('Nenhum horário disponível para este dia.'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _availableTimeSlots.length,
                          itemBuilder: (context, index) {
                            final timeSlot = _availableTimeSlots[index];
                            final isSelected = _selectedTimeSlot == timeSlot;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTimeSlot = timeSlot;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('HH:mm').format(timeSlot),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Confirmation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTimeSlot == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              service: widget.service,
                              selectedDateTime: _selectedTimeSlot!,
                            ),
                          ),
                        );
                      },
                child: const Text('Avançar para Confirmação'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
