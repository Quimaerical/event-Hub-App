import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
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
      await _fetchData(emit, query: event.query, categoryId: currentState.selectedCategoryId);
    }
  }

  Future<void> _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardLoading());
      await _fetchData(emit, query: currentState.searchQuery, categoryId: event.categoryId);
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
        queryParameters['category'] = categoryId.toString();
      }

      final response = await apiClient.dio.get(
        '/',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      
      final eventsJson = data['eventos'] as List? ?? [];
      final categoriesJson = data['categorias'] as List? ?? [];

      final events = eventsJson.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
      final categories = categoriesJson.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();

      emit(DashboardLoaded(
        events: events,
        categories: categories,
        searchQuery: query,
        selectedCategoryId: categoryId,
      ));
    } catch (e) {
      emit(DashboardFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
