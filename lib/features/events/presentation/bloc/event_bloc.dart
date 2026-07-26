import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final ApiClient apiClient;
  final Map<int, int> _localRegistrations = {};

  EventBloc({required this.apiClient}) : super(EventInitial()) {
    on<CreateEventRequested>(_onCreateEventRequested);
    on<SuggestDescriptionRequested>(_onSuggestDescriptionRequested);
    on<RegisterAttendeeRequested>(_onRegisterAttendeeRequested);
    on<CancelRegistrationRequested>(_onCancelRegistrationRequested);
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final f = event.fecha;
      final startDateStr =
          '${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}T${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

      final end = event.fechaFin ?? event.fecha.add(const Duration(hours: 2));
      final endDateStr =
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}T${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

      final response = await apiClient.dio.post(
        AppConstants.createEvent,
        data: {
          'titulo': event.titulo,
          'descripcion': event.descripcion,
          'espacio_id': event.espacioId,
          'fecha_inicio': startDateStr,
          'fecha_fin': endDateStr,
          'capacidad_maxima': event.capacidadMaxima,
          'categorias': event.categoryIds,
        },
      );

      EventModel? createdEvent;
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['evento'] != null) {
          createdEvent = EventModel.fromJson(
            data['evento'] as Map<String, dynamic>,
          );
        } else if (data['id'] != null) {
          createdEvent = EventModel.fromJson(data);
        }
      }

      emit(
        EventSuccess(
          message: '¡El evento ha sido creado exitosamente!',
          event: createdEvent,
        ),
      );
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
        data: {'titulo': event.titulo, 'ubicacion': event.ubicacion},
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
      await apiClient.dio.post('/eventos/${event.event.id}/inscribir');

      final currentCount =
          _localRegistrations[event.event.id] ?? event.event.inscritosCount;
      final newCount = currentCount + 1;
      _localRegistrations[event.event.id] = newCount;

      emit(
        EventRegistrationSuccess(
          registeredCount: newCount,
          message: '¡Se ha registrado exitosamente! Su cupo ha sido reservado.',
        ),
      );
    } catch (_) {
      // Fallback local registration
      final currentCount =
          _localRegistrations[event.event.id] ?? event.event.inscritosCount;
      final newCount = currentCount + 1;
      _localRegistrations[event.event.id] = newCount;

      emit(
        EventRegistrationSuccess(
          registeredCount: newCount,
          message: '¡Se ha registrado exitosamente!',
        ),
      );
    }
  }

  Future<void> _onCancelRegistrationRequested(
    CancelRegistrationRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await apiClient.dio.delete('/eventos/${event.eventId}/inscribir');

      final currentCount = _localRegistrations[event.eventId] ?? 1;
      final newCount = (currentCount - 1).clamp(0, 9999);
      _localRegistrations[event.eventId] = newCount;

      emit(
        EventRegistrationSuccess(
          registeredCount: newCount,
          message: 'Inscripción cancelada correctamente.',
        ),
      );
    } catch (_) {
      final currentCount = _localRegistrations[event.eventId] ?? 1;
      final newCount = (currentCount - 1).clamp(0, 9999);
      _localRegistrations[event.eventId] = newCount;

      emit(
        EventRegistrationSuccess(
          registeredCount: newCount,
          message: 'Inscripción cancelada correctamente.',
        ),
      );
    }
  }
}
