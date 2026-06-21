import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../events/presentation/screens/create_event_screen.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/models/category_model.dart';
import '../../../events/data/models/event_model.dart';

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
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryViolet),
              );
            } else if (state is DashboardFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        state.error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData()),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is DashboardLoaded) {
              return Column(
                children: [
                  // Search Bar Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        context.read<DashboardBloc>().add(SearchQueryChanged(query: val));
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar eventos...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                  context.read<DashboardBloc>().add(SearchQueryChanged(query: ''));
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Scrollable Categories Chip Filters
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: state.categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final CategoryModel? category = isAll ? null : state.categories[index - 1];
                        final id = isAll ? 0 : category!.id;
                        final name = isAll ? 'Todas' : category!.nombre;
                        final isSelected = state.selectedCategoryId == id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                          child: ChoiceChip(
                            label: Text(name),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryViolet,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            backgroundColor: AppTheme.cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryViolet : AppTheme.borderDark,
                              ),
                            ),
                            onSelected: (_) {
                              context.read<DashboardBloc>().add(CategoryFilterChanged(categoryId: id));
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Dynamic Events ListView
                  Expanded(
                    child: state.events.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: AppTheme.primaryViolet,
                            onRefresh: () async {
                              context.read<DashboardBloc>().add(LoadDashboardData());
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: state.events.length,
                              itemBuilder: (context, index) {
                                final event = state.events[index];
                                return _buildEventCard(context, event);
                              },
                            ),
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryViolet,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron eventos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
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

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Badges List
              if (event.categorias.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: event.categorias.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryViolet.withOpacity(0.1),
                        border: Border.all(color: AppTheme.primaryViolet.withOpacity(0.2), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.nombre.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryViolet,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),

              // Title
              Text(
                event.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),

              // Short Description
              Text(
                event.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Calendar and Pin Location Row
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.primaryViolet),
                  const SizedBox(width: 6),
                  Text(
                    '${event.fecha.day}/${event.fecha.month}/${event.fecha.year} ${event.fecha.hour.toString().padLeft(2, '0')}:${event.fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primaryViolet),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.ubicacion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
