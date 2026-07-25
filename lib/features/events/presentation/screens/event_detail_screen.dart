import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/event_model.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import 'create_event_screen.dart';

/// Alias for conventional naming
typedef DetailView = EventDetailScreen;

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late int _registeredCount;
  bool _isRegistered = false;
  late EventModel _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _registeredCount = widget.event.inscritosCount;
  }

  void _handleRegisterToggle(bool isLoading) async {
    if (isLoading) return;

    if (_isRegistered) {
      // Cancel registration
      context.read<EventBloc>().add(
        CancelRegistrationRequested(eventId: _currentEvent.id),
      );
      if (!mounted) return;
      setState(() {
        _isRegistered = false;
        if (_registeredCount > 0) _registeredCount--;
      });
    } else {
      // Register for event
      context.read<EventBloc>().add(
        RegisterAttendeeRequested(event: _currentEvent),
      );
    }
  }

  void _onDeleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Eliminar Evento',
          style: TextStyle(color: AppTheme.textLight),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de eliminación enviada.'),
          backgroundColor: AppTheme.skyBlue,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _onApproveEvent() {
    setState(() {
      _currentEvent = _currentEvent.copyWith(estado: 'Aprobado');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El evento ha sido APROBADO exitosamente.'),
        backgroundColor: AppTheme.seaGreen,
      ),
    );
  }

  void _onRejectEvent() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Rechazar Evento',
          style: TextStyle(color: AppTheme.textLight),
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Ingrese observaciones o motivo de rechazo...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(reasonController.text),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentEvent = _currentEvent.copyWith(estado: 'Cancelado');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento rechazado. Observaciones: $result'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    int? currentUserId;
    String? currentUserRole;

    if (authState is Authenticated) {
      currentUserId = authState.userId;
      currentUserRole = authState.userRole;
    }

    final isOrganizer =
        currentUserId != null && currentUserId == _currentEvent.creadorId;
    final isAdminOrApprover =
        currentUserRole == 'admin' || currentUserRole == 'aprobador';

    final hasAvailableSpots = _registeredCount < _currentEvent.cupoMaximo;
    final isActive = _currentEvent.estado != 'Cancelado';

    return Scaffold(
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventRegistrationSuccess) {
            setState(() {
              _registeredCount = state.registeredCount;
              _isRegistered = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.seaGreen,
              ),
            );
          } else if (state is EventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Image / Gradient with Floating Back Button
                  _EventDetailHeader(imageUrl: _currentEvent.imagenUrl),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Category Badges & Event Status Badge
                        _EventStatusAndCategories(
                          categories: _currentEvent.categorias,
                          status: _currentEvent.estado,
                        ),
                        const SizedBox(height: 14),

                        // 3. Title
                        Text(
                          _currentEvent.titulo,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. Detailed Info Rows (Date/Time, Location, Organizer)
                        _EventMetadataSection(event: _currentEvent),
                        const SizedBox(height: 20),

                        // 5. Capacity & Registered Progress Card
                        _CapacityProgressCard(
                          registeredCount: _registeredCount,
                          maxCapacity: _currentEvent.cupoMaximo,
                        ),
                        const SizedBox(height: 24),

                        // 6. About / Full Description Section
                        const Text(
                          'Sobre este evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentEvent.descripcion,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 7. Primary Dynamic Action Button (Reserve / Cancel / Full)
                        _PrimaryActionButtonSection(
                          isRegistered: _isRegistered,
                          hasAvailableSpots: hasAvailableSpots,
                          isActive: isActive,
                          onPressed: _handleRegisterToggle,
                        ),
                        const SizedBox(height: 20),

                        // 8. Conditional Admin / Organizer Actions
                        if (isOrganizer || isAdminOrApprover)
                          _AdminActionsSection(
                            isOrganizer: isOrganizer,
                            isAdminOrApprover: isAdminOrApprover,
                            onEdit: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final updated = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => CreateEventScreen(
                                    eventToEdit: _currentEvent,
                                  ),
                                ),
                              );
                              if (updated == true && mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Evento actualizado correctamente.',
                                    ),
                                    backgroundColor: AppTheme.seaGreen,
                                  ),
                                );
                              }
                            },
                            onDelete: _onDeleteEvent,
                            onApprove: _onApproveEvent,
                            onReject: _onRejectEvent,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventDetailHeader extends StatelessWidget {
  final String? imageUrl;

  const _EventDetailHeader({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppTheme.cardBg,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.skyBlue,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const _HeaderGradientFallback(),
                )
              : const _HeaderGradientFallback(),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderGradientFallback extends StatelessWidget {
  const _HeaderGradientFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.skyBlue, AppTheme.seaGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event, size: 64, color: Colors.white),
      ),
    );
  }
}

class _EventStatusAndCategories extends StatelessWidget {
  final List<dynamic> categories;
  final String status;

  const _EventStatusAndCategories({
    required this.categories,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'aprobado':
        statusColor = AppTheme.seaGreen;
        break;
      case 'en revisión':
      case 'en revision':
        statusColor = Colors.amber;
        break;
      case 'cancelado':
      case 'rechazado':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = AppTheme.skyBlue;
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        // Categories Badges
        ...categories.map((c) {
          final String name = c is String ? c : c.nombre.toString();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.skyBlue.withValues(alpha: 0.15),
              border: Border.all(
                color: AppTheme.skyBlue.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.skyBlue,
                letterSpacing: 0.5,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EventMetadataSection extends StatelessWidget {
  final EventModel event;

  const _EventMetadataSection({required this.event});

  @override
  Widget build(BuildContext context) {
    final String startDateStr =
        '${event.fecha.day}/${event.fecha.month}/${event.fecha.year} ${event.fecha.hour.toString().padLeft(2, '0')}:${event.fecha.minute.toString().padLeft(2, '0')}';
    final String dateDisplay = event.fechaFin != null
        ? '$startDateStr - ${event.fechaFin!.hour.toString().padLeft(2, '0')}:${event.fechaFin!.minute.toString().padLeft(2, '0')}'
        : startDateStr;

    return Column(
      children: [
        // Date & Time
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.skyBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha y Hora',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    dateDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Location
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppTheme.skyBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación / Sala',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    event.ubicacion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Organizer
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: AppTheme.seaGreen,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organizador',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    event.organizadorNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.seaGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CapacityProgressCard extends StatelessWidget {
  final int registeredCount;
  final int maxCapacity;

  const _CapacityProgressCard({
    required this.registeredCount,
    required this.maxCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = maxCapacity > 0
        ? (registeredCount / maxCapacity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Capacidad del Evento',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$registeredCount / $maxCapacity Asistentes',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.skyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppTheme.borderDark,
              color: percentage >= 1.0 ? Colors.redAccent : AppTheme.skyBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButtonSection extends StatelessWidget {
  final bool isRegistered;
  final bool hasAvailableSpots;
  final bool isActive;
  final ValueChanged<bool> onPressed;

  const _PrimaryActionButtonSection({
    required this.isRegistered,
    required this.hasAvailableSpots,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        final isLoading = state is EventLoading;

        if (!isActive) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cardBg,
                disabledBackgroundColor: AppTheme.cardBg,
              ),
              child: const Text(
                'Evento Cancelado / Inactivo',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        if (!isRegistered && !hasAvailableSpots) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cardBg,
                disabledBackgroundColor: AppTheme.cardBg,
              ),
              child: const Text(
                'Cupos Agotados',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => onPressed(isLoading),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRegistered
                  ? AppTheme.cardBg
                  : AppTheme.seaGreen,
              foregroundColor: isRegistered ? Colors.redAccent : Colors.white,
              side: isRegistered
                  ? const BorderSide(color: Colors.redAccent)
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isRegistered ? 'Cancelar Inscripción' : 'Reservar mi Lugar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _AdminActionsSection extends StatelessWidget {
  final bool isOrganizer;
  final bool isAdminOrApprover;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AdminActionsSection({
    required this.isOrganizer,
    required this.isAdminOrApprover,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCIONES DE ADMINISTRACIÓN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (isOrganizer) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.skyBlue,
                      size: 18,
                    ),
                    label: const Text(
                      'Editar Evento',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.skyBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isAdminOrApprover) ...[
            if (isOrganizer) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Aprobar Evento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.seaGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Rechazar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
