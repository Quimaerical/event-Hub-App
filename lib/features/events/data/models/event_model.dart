import 'package:flutter/foundation.dart';
import '../../../dashboard/data/models/category_model.dart';

@immutable
class EventModel {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final DateTime? fechaFin;
  final String ubicacion;
  final int creadorId;
  final String creadorNombre;
  final List<CategoryModel> categorias;
  final int cupoMaximo; // local capacity limit
  final int inscritosCount;
  final String estado; // 'Aprobado', 'En revisión', 'Cancelado'
  final DateTime createdAt;
  final String? imagenUrl;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.fechaFin,
    required this.ubicacion,
    required this.creadorId,
    required this.creadorNombre,
    required this.categorias,
    this.cupoMaximo = 50, // default limit
    this.inscritosCount = 0,
    this.estado = 'Aprobado',
    required this.createdAt,
    this.imagenUrl,
  });

  String get organizadorNombre => creadorNombre;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    var catsJson = json['categorias'] as List?;
    List<CategoryModel> cats = catsJson != null
        ? catsJson
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : [];

    DateTime parsedFecha = DateTime.now();
    if (json['fecha'] != null) {
      parsedFecha =
          DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now();
    }

    DateTime? parsedFechaFin;
    if (json['fecha_fin'] != null) {
      parsedFechaFin = DateTime.tryParse(json['fecha_fin'].toString());
    }

    DateTime parsedCreated = DateTime.now();
    if (json['created_at'] != null) {
      parsedCreated =
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return EventModel(
      id: json['id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      fecha: parsedFecha,
      fechaFin: parsedFechaFin,
      ubicacion: json['ubicacion'] as String? ?? '',
      creadorId: json['creador_id'] as int? ?? 0,
      creadorNombre: json['creador_nombre'] as String? ?? 'Organizador',
      categorias: cats,
      cupoMaximo: json['cupo_maximo'] as int? ?? 50,
      inscritosCount: json['inscritos_count'] as int? ?? 0,
      estado: json['estado']?.toString() ?? 'Aprobado',
      createdAt: parsedCreated,
      imagenUrl: json['imagen_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'ubicacion': ubicacion,
      'creador_id': creadorId,
      'creador_nombre': creadorNombre,
      'categorias': categorias.map((e) => e.toJson()).toList(),
      'cupo_maximo': cupoMaximo,
      'inscritos_count': inscritosCount,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'imagen_url': imagenUrl,
    };
  }

  EventModel copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    DateTime? fechaFin,
    String? ubicacion,
    int? creadorId,
    String? creadorNombre,
    List<CategoryModel>? categorias,
    int? cupoMaximo,
    int? inscritosCount,
    String? estado,
    DateTime? createdAt,
    String? imagenUrl,
  }) {
    return EventModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      fechaFin: fechaFin ?? this.fechaFin,
      ubicacion: ubicacion ?? this.ubicacion,
      creadorId: creadorId ?? this.creadorId,
      creadorNombre: creadorNombre ?? this.creadorNombre,
      categorias: categorias ?? this.categorias,
      cupoMaximo: cupoMaximo ?? this.cupoMaximo,
      inscritosCount: inscritosCount ?? this.inscritosCount,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
