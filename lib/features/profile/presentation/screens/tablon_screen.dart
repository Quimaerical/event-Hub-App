import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../events/presentation/bloc/event_event.dart';
import '../../../events/presentation/bloc/event_state.dart';
import '../../../events/presentation/screens/create_event_screen.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';

/// Alias for conventional naming
typedef TablonView = TablonScreen;

class TablonScreen extends StatefulWidget {
  const TablonScreen({super.key});

  @override
  State<TablonScreen> createState() => _TablonScreenState();
}

class _TablonScreenState extends State<TablonScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userEmail = '';
    int? userId;

    if (authState is Authenticated) {
      userEmail = authState.email;
      userId = authState.userId;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Tablón de Eventos'),
          bottom: const TabBar(
            indicatorColor: AppTheme.skyBlue,
            labelColor: AppTheme.skyBlue,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(icon: Icon(Icons.event_available), text: 'Asistiré'),
              Tab(icon: Icon(Icons.stars), text: 'Mis Eventos'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocListener<EventBloc, EventState>(
              listener: (context, state) {
                if (state is EventRegistrationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.seaGreen,
                    ),
                  );
                  context.read<DashboardBloc>().add(LoadDashboardData());
                }
              },
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading || state is DashboardInitial) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.skyBlue),
                    );
                  }

                  if (state is DashboardLoaded) {
                    final allEvents = state.events;

                    // Filter events created by user
                    final myEvents = allEvents.where((e) {
                      if (userId != null) return e.creadorId == userId;
                      return e.creadorNombre == userEmail ||
                          e.organizadorNombre == userEmail;
                    }).toList();

                    // Filter events user is attending (for demo purposes, non-empty list or first half)
                    final attendingEvents = allEvents
                        .where(
                          (e) => e.inscritosCount > 0 || myEvents.contains(e),
                        )
                        .toList();

                    return TabBarView(
                      children: [
                        // Tab 1: Asistiré
                        _AttendingEventsTab(
                          events: attendingEvents,
                          onRefresh: () async {
                            context.read<DashboardBloc>().add(
                              LoadDashboardData(),
                            );
                          },
                        ),

                        // Tab 2: Mis Eventos
                        _MyCreatedEventsTab(
                          events: myEvents,
                          onRefresh: () async {
                            context.read<DashboardBloc>().add(
                              LoadDashboardData(),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const _EmptyTablonState(
                    message: 'No se pudieron cargar los datos de tu tablón.',
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendingEventsTab extends StatelessWidget {
  final List<EventModel> events;
  final RefreshCallback onRefresh;

  const _AttendingEventsTab({required this.events, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyTablonState(
        message:
            'Aún no te has inscrito a ningún evento.\n¡Explora la cartelera y reserva tu lugar!',
      );
    }

    return RefreshIndicator(
      color: AppTheme.skyBlue,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _TablonEventCard(event: event, isMyEvent: false);
        },
      ),
    );
  }
}

class _MyCreatedEventsTab extends StatelessWidget {
  final List<EventModel> events;
  final RefreshCallback onRefresh;

  const _MyCreatedEventsTab({required this.events, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyTablonState(
        message:
            'Aún no has publicado ningún evento.\n¡Crea tu primer evento con ayuda de la IA!',
      );
    }

    return RefreshIndicator(
      color: AppTheme.skyBlue,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _TablonEventCard(event: event, isMyEvent: true);
        },
      ),
    );
  }
}

class _TablonEventCard extends StatelessWidget {
  final EventModel event;
  final bool isMyEvent;

  const _TablonEventCard({required this.event, required this.isMyEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: AppTheme.darkGlassDecoration,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TablonStatusBadge(status: event.estado),
              Text(
                '${event.fecha.day}/${event.fecha.month}/${event.fecha.year}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event.ubicacion,
            style: const TextStyle(fontSize: 13, color: AppTheme.skyBlue),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  label: const Text(
                    'Ver Detalle',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.borderDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isMyEvent)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final bloc = context.read<DashboardBloc>();
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CreateEventScreen(eventToEdit: event),
                        ),
                      );
                      if (result == true && context.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Evento modificado correctamente.'),
                            backgroundColor: AppTheme.seaGreen,
                          ),
                        );
                        bloc.add(LoadDashboardData());
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text('Editar', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<EventBloc>().add(
                        CancelRegistrationRequested(eventId: event.id),
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TablonStatusBadge extends StatelessWidget {
  final String status;

  const _TablonStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'aprobado':
        badgeColor = AppTheme.seaGreen;
        break;
      case 'en revisión':
      case 'en revision':
        badgeColor = Colors.amber;
        break;
      case 'cancelado':
        badgeColor = Colors.redAccent;
        break;
      default:
        badgeColor = AppTheme.skyBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _EmptyTablonState extends StatelessWidget {
  final String message;

  const _EmptyTablonState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 54,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
