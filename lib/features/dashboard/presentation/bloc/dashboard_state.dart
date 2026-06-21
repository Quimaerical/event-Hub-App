import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import '../../../events/data/models/event_model.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<EventModel> events;
  final List<CategoryModel> categories;
  final String searchQuery;
  final int selectedCategoryId;

  DashboardLoaded({
    required this.events,
    required this.categories,
    required this.searchQuery,
    required this.selectedCategoryId,
  });

  DashboardLoaded copyWith({
    List<EventModel>? events,
    List<CategoryModel>? categories,
    String? searchQuery,
    int? selectedCategoryId,
  }) {
    return DashboardLoaded(
      events: events ?? this.events,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class DashboardFailure extends DashboardState {
  final String error;

  DashboardFailure({required this.error});
}
