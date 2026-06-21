import 'package:flutter/foundation.dart';
import '../../data/models/event_model.dart';

@immutable
abstract class EventEvent {}

// Publish a new event
class CreateEventRequested extends EventEvent {
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String ubicacion;
  final List<int> categoryIds;

  CreateEventRequested({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
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
