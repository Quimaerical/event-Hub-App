import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../events/presentation/screens/create_event_screen.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/category_filter_list.dart';
import '../widgets/dashboard_hero.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/event_card.dart';

/// Alias for conventional naming
typedef DashboardView = DashboardScreen;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EventHub'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Cerrar Sesión',
              onPressed: _onLogout,
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading || state is DashboardInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.skyBlue),
                  );
                } else if (state is DashboardFailure) {
                  return _DashboardErrorView(
                    errorMessage: state.error,
                    onRetry: () =>
                        context.read<DashboardBloc>().add(LoadDashboardData()),
                  );
                } else if (state is DashboardLoaded) {
                  return RefreshIndicator(
                    color: AppTheme.skyBlue,
                    onRefresh: () async {
                      context.read<DashboardBloc>().add(LoadDashboardData());
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const DashboardHero(),
                                const SizedBox(height: 20),
                                DashboardSearchBar(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    context.read<DashboardBloc>().add(
                                      SearchQueryChanged(query: val),
                                    );
                                  },
                                  onClear: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                    context.read<DashboardBloc>().add(
                                      SearchQueryChanged(query: ''),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                CategoryFilterList(
                                  categories: state.categories,
                                  selectedCategoryId: state.selectedCategoryId,
                                  onCategorySelected: (id) {
                                    context.read<DashboardBloc>().add(
                                      CategoryFilterChanged(categoryId: id),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        if (state.events.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _DashboardEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            sliver: SliverLayoutBuilder(
                              builder: (context, constraints) {
                                final isWide =
                                    constraints.crossAxisExtent > 500;
                                final crossAxisCount = isWide ? 2 : 1;

                                return SliverGrid(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final event = state.events[index];
                                    return EventCard(event: event);
                                  }, childCount: state.events.length),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: isWide ? 0.72 : 0.85,
                                      ),
                                );
                              },
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.skyBlue,
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateEventScreen()),
            );
            if (result == true && context.mounted) {
              context.read<DashboardBloc>().add(LoadDashboardData());
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron eventos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pruebe ajustando los filtros de búsqueda o categoría.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _DashboardErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
