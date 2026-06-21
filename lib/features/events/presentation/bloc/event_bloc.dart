import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final ApiClient apiClient;
  // Local register cache to trace simulated bookings and check limits
  final Map<int, int> _localRegistrations = {};

  EventBloc({required this.apiClient}) : super(EventInitial()) {
    on<CreateEventRequested>(_onCreateEventRequested);
    on<SuggestDescriptionRequested>(_onSuggestDescriptionRequested);
    on<RegisterAttendeeRequested>(_onRegisterAttendeeRequested);
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      // Re-format DateTime to match Go parsing format (YYYY-MM-DDTHH:MM)
      final formattedDate = event.fecha.toIso8601String().substring(0, 16);

      final response = await apiClient.dio.post(
        AppConstants.createEvent,
        data: {
          'titulo': event.titulo,
          'descripcion': event.descripcion,
          'fecha': formattedDate,
          'ubicacion': event.ubicacion,
          'categorias': event.categoryIds.map((id) => id.toString()).toList(),
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final createdEvent = data['evento'] != null
          ? EventModel.fromJson(data['evento'] as Map<String, dynamic>)
          : null;

      emit(EventSuccess(
        message: '¡El evento ha sido creado exitosamente!',
        event: createdEvent,
      ));
    } catch (e) {
      emit(EventFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSuggestDescriptionRequested(
    SuggestDescriptionRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final response = await apiClient.dio.post(
        AppConstants.suggestDescription,
        data: {
          'titulo': event.titulo,
          'ubicacion': event.ubicacion,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final suggestion = data['descripcion'] as String? ?? '';

      emit(GeminiSuggestionSuccess(suggestion: suggestion));
    } catch (e) {
      emit(EventFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterAttendeeRequested(
    RegisterAttendeeRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final currentCount = _localRegistrations[event.event.id] ?? 0;

      // Validate capacity limit checks
      if (currentCount >= event.event.cupoMaximo) {
        emit(EventFailure(
          error: 'Lo sentimos, este evento ha alcanzado el límite máximo de ${event.event.cupoMaximo} personas.',
        ));
        return;
      }

      final newCount = currentCount + 1;
      _localRegistrations[event.event.id] = newCount;

      emit(EventRegistrationSuccess(
        registeredCount: newCount,
        message: '¡Se ha registrado exitosamente! Su cupo ha sido reservado.',
      ));
    } catch (e) {
      emit(EventFailure(error: e.toString()));
    }
  }
}
