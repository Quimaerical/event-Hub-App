import 'package:flutter/foundation.dart';

@immutable
abstract class DashboardEvent {}

// Fetch initial events and categories list
class LoadDashboardData extends DashboardEvent {}

// Triggered when text search query changes
class SearchQueryChanged extends DashboardEvent {
  final String query;

  SearchQueryChanged({required this.query});
}

// Triggered when user picks a category pill filter
class CategoryFilterChanged extends DashboardEvent {
  final int categoryId;

  CategoryFilterChanged({required this.categoryId});
}
