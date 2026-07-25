import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final int id;
  final String nombre;
  final String email;
  final int? roleId;
  final String? roleNombre;
  final String? departamento;
  final String? telefono;

  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.roleId,
    this.roleNombre,
    this.departamento,
    this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roleId: json['role_id'] as int?,
      roleNombre: json['role_nombre']?.toString(),
      departamento: json['departamento']?.toString(),
      telefono: json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'role_id': roleId,
      'role_nombre': roleNombre,
      'departamento': departamento,
      'telefono': telefono,
    };
  }
}
