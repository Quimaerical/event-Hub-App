import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/category_model.dart';
import '../../../events/data/models/event_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiClient apiClient;

  DashboardBloc({required this.apiClient}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _fetchData(emit, query: '', categoryId: 0);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardLoading());
      await _fetchData(
        emit,
        query: event.query,
        categoryId: currentState.selectedCategoryId,
      );
    }
  }

  Future<void> _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardLoading());
      await _fetchData(
        emit,
        query: currentState.searchQuery,
        categoryId: event.categoryId,
      );
    }
  }

  Future<void> _fetchData(
    Emitter<DashboardState> emit, {
    required String query,
    required int categoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (query.isNotEmpty) {
        queryParameters['search'] = query;
      }
      if (categoryId > 0) {
        queryParameters['category_id'] = categoryId.toString();
      }

      // 1. Fetch events from /api/v1/eventos
      final eventsResponse = await apiClient.dio.get(
        AppConstants.events,
        queryParameters: queryParameters,
      );

      List<EventModel> events = [];
      if (eventsResponse.data is Map &&
          eventsResponse.data['eventos'] is List) {
        final eventsJson = eventsResponse.data['eventos'] as List;
        events = eventsJson
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (eventsResponse.data is List) {
        events = (eventsResponse.data as List)
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // 2. Fetch categories from /api/v1/categorias
      List<CategoryModel> categories = [];
      try {
        final categoriesResponse = await apiClient.dio.get(
          AppConstants.categories,
        );
        if (categoriesResponse.data is Map &&
            categoriesResponse.data['categorias'] is List) {
          final catsJson = categoriesResponse.data['categorias'] as List;
          categories = catsJson
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Fallback: keep categories empty or soft handle
      }

      emit(
        DashboardLoaded(
          events: events,
          categories: categories,
          searchQuery: query,
          selectedCategoryId: categoryId,
        ),
      );
    } catch (e) {
      emit(DashboardFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
