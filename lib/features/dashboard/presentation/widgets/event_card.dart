import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';

class EventCard extends StatefulWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark
        ? AppTheme.darkGlassDecoration
        : AppTheme.lightGlassDecoration;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onHighlightChanged: (value) {
              setState(() {
                _isPressed = value;
              });
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: widget.event),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image with Progressive Loading & Fallback
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildEventImage(widget.event.imagenUrl),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badges matching views/dashboard/index.html (bg-brand-900/40)
                      if (widget.event.categorias.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.event.categorias.map((c) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.brandDark.withValues(
                                  alpha: 0.4,
                                ),
                                border: Border.all(
                                  color: AppTheme.brandViolet.withValues(
                                    alpha: 0.25,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                c.nombre.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.brandLight,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 10),

                      // Title (Max 2 lines, truncated)
                      Text(
                        widget.event.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textLight,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description (Max 3 lines, truncated)
                      Text(
                        widget.event.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date and Location Information
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: AppTheme.brandViolet,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.event.fecha.day}/${widget.event.fecha.month}/${widget.event.fecha.year} ${widget.event.fecha.hour.toString().padLeft(2, '0')}:${widget.event.fecha.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.brandViolet,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.event.ubicacion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Organizer Info & Ver Detalle action matching views/dashboard/index.html
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppTheme.brandDeep
                                      .withValues(alpha: 0.3),
                                  child: Text(
                                    widget.event.organizadorNombre.isNotEmpty
                                        ? widget.event.organizadorNombre[0]
                                              .toUpperCase()
                                        : 'O',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.brandLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Por ${widget.event.organizadorNombre}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Row(
                            children: [
                              Text(
                                'Ver Detalle',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.brandViolet,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AppTheme.brandViolet,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.cardBg,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppTheme.brandViolet,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.brandDeep, AppTheme.darkBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event, size: 44, color: AppTheme.brandLight),
      ),
    );
  }
}
