import 'package:flutter/foundation.dart';
import '../../data/models/event_model.dart';

@immutable
abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventSuccess extends EventState {
  final String message;
  final EventModel? event;

  EventSuccess({required this.message, this.event});
}

class GeminiSuggestionSuccess extends EventState {
  final String suggestion;

  GeminiSuggestionSuccess({required this.suggestion});
}

class EventRegistrationSuccess extends EventState {
  final int registeredCount;
  final String message;

  EventRegistrationSuccess({required this.registeredCount, required this.message});
}

class EventFailure extends EventState {
  final String error;

  EventFailure({required this.error});
}
