import 'package:flutter/foundation.dart';

@immutable
class CategoryModel {
  final int id;
  final String nombre;
  final String descripcion;

  const CategoryModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
