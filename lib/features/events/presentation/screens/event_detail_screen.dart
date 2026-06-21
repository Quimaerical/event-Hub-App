import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _registeredCount = 0;
  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Evento'),
      ),
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
                backgroundColor: Colors.green,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badges List
              if (event.categorias.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.categorias.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryViolet.withOpacity(0.1),
                        border: Border.all(color: AppTheme.primaryViolet.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c.nombre.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryViolet,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Title
              Text(
                event.titulo,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Organizer Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryViolet,
                      radius: 18,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organizador',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        Text(
                          event.creadorNombre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Event Metadata Rows (Date & Location)
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryViolet, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha y Hora', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      Text(
                        '${event.fecha.day}/${event.fecha.month}/${event.fecha.year} ${event.fecha.hour.toString().padLeft(2, '0')}:${event.fecha.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryViolet, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ubicación o Enlace', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text(
                          event.ubicacion,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Divider
              const Divider(color: AppTheme.borderDark),
              const SizedBox(height: 16),

              // Full Description
              const Text(
                'Sobre este evento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
              const SizedBox(height: 8),
              Text(
                event.descripcion,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Local registry / cupo limit status card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryViolet.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryViolet.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Capacidad del Evento', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          '$_registeredCount / ${event.cupoMaximo} Inscritos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    _isRegistered
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Registration booking trigger button
              BlocBuilder<EventBloc, EventState>(
                builder: (context, state) {
                  final isLoading = state is EventLoading;
                  return ElevatedButton(
                    onPressed: _isRegistered || isLoading
                        ? null
                        : () {
                            context.read<EventBloc>().add(RegisterAttendeeRequested(event: event));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRegistered ? AppTheme.cardBg : AppTheme.primaryViolet,
                      foregroundColor: _isRegistered ? AppTheme.textMuted : Colors.white,
                      side: _isRegistered ? const BorderSide(color: AppTheme.borderDark) : null,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isRegistered ? 'Inscrito Correctamente' : 'Inscribirse al Evento'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
