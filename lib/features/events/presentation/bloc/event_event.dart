import 'package:flutter/foundation.dart';
import '../../data/models/event_model.dart';

@immutable
abstract class EventEvent {}

// Publish a new event
class CreateEventRequested extends EventEvent {
  final String titulo;
  final String descripcion;
  final int espacioId;
  final DateTime fecha;
  final DateTime? fechaFin;
  final int capacidadMaxima;
  final String ubicacion;
  final List<int> categoryIds;

  CreateEventRequested({
    required this.titulo,
    required this.descripcion,
    required this.espacioId,
    required this.fecha,
    this.fechaFin,
    required this.capacidadMaxima,
    required this.ubicacion,
    required this.categoryIds,
  });
}

// Request description suggestion from Gemini
class SuggestDescriptionRequested extends EventEvent {
  final String titulo;
  final String ubicacion;

  SuggestDescriptionRequested({required this.titulo, required this.ubicacion});
}

// Locally registers attendance for an event with capacity limit checks
class RegisterAttendeeRequested extends EventEvent {
  final EventModel event;

  RegisterAttendeeRequested({required this.event});
}

// Cancels attendance registration for an event
class CancelRegistrationRequested extends EventEvent {
  final int eventId;

  CancelRegistrationRequested({required this.eventId});
}
