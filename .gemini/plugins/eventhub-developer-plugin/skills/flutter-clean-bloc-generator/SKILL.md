---
name: flutter-clean-bloc-generator
description: Generates clean architecture directories and BLoC boilerplate for Flutter features in the Event Hub application.
---

# Flutter Clean Architecture & BLoC Generator

## Overview
Esta skill guía a los agentes y desarrolladores para generar de manera consistente e impecable nuevos módulos (Features) dentro de la aplicación móvil Flutter. Garantiza que cada nueva característica cumpla con la segregación de responsabilidades de Clean Architecture y la gestión del estado a través de `flutter_bloc`.

## Estructura de Directorios Requerida
Cada nueva feature llamada `<feature_name>` debe tener la siguiente estructura:

```text
lib/features/<feature_name>/
├── data/
│   ├── models/           # Modelos de datos inmutables y métodos fromJson/toJson
│   └── repositories/     # Implementación concreta de la interfaz del repositorio
│       └── <feature_name>_repository_impl.dart
├── domain/
│   └── repositories/     # Contrato/Interfaz abstracta para el repositorio
│       └── <feature_name>_repository.dart
└── presentation/
    ├── bloc/             # Lógica del BLoC para control del estado
    │   ├── <feature_name>_bloc.dart
    │   ├── <feature_name>_event.dart
    │   └── <feature_name>_state.dart
    └── screens/          # Pantallas e interfaces de usuario reactivas
        └── <feature_name>_screen.dart
```

---

## 📄 Plantillas Estructuradas

### 1. Modelo de Datos Inmutable (Data Layer)
Los modelos deben ser inmutables y definir métodos de serialización sencillos sin mutar propiedades directamente.
```dart
import 'package:meta/meta.dart';

@immutable
class ExampleModel {
  final int id;
  final String title;

  const ExampleModel({
    required this.id,
    required this.title,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  ExampleModel copyWith({
    int? id,
    String? title,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
```

### 2. Contrato de Repositorio (Domain Layer)
```dart
import '../data/models/example_model.dart'; // Ajusta la ruta

abstract class ExampleRepository {
  Future<List<ExampleModel>> fetchItems();
  Future<void> createItem(String title);
}
```

### 3. Implementación de Repositorio (Data Layer)
Utiliza centralizadamente el `ApiClient` para las peticiones HTTP Dio, el cual ya inyecta el token de sesión.
```dart
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/example_repository.dart';
import '../models/example_model.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ApiClient apiClient;

  ExampleRepositoryImpl({required this.apiClient});

  @override
  Future<List<ExampleModel>> fetchItems() async {
    try {
      final response = await apiClient.dio.get('/api/examples');
      final data = response.data as List;
      return data.map((json) => ExampleModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener elementos: $e');
    }
  }

  @override
  Future<void> createItem(String title) async {
    try {
      await apiClient.dio.post(
        '/api/examples',
        data: {'title': title},
      );
    } catch (e) {
      throw Exception('Error al crear elemento: $e');
    }
  }
}
```

### 4. Eventos y Estados del BLoC (Presentation Layer)
**Eventos (`example_event.dart`):**
```dart
import 'package:meta/meta.dart';

@immutable
abstract class ExampleEvent {
  const ExampleEvent();
}

class LoadExamples extends ExampleEvent {
  const LoadExamples();
}
```

**Estados (`example_state.dart`):**
```dart
import 'package:meta/meta.dart';
import '../../data/models/example_model.dart';

@immutable
abstract class ExampleState {
  const ExampleState();
}

class ExampleInitial extends ExampleState {}
class ExampleLoading extends ExampleState {}
class ExampleLoaded extends ExampleState {
  final List<ExampleModel> items;
  const ExampleLoaded(this.items);
}
class ExampleFailure extends ExampleState {
  final String message;
  const ExampleFailure(this.message);
}
```

**BLoC (`example_bloc.dart`):**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/example_repository.dart';
import 'example_event.dart';
import 'example_state.dart';

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final ExampleRepository repository;

  ExampleBloc({required this.repository}) : super(ExampleInitial()) {
    on<LoadExamples>(_onLoadExamples);
  }

  Future<void> _onLoadExamples(
    LoadExamples event,
    Emitter<ExampleState> emit,
  ) async {
    emit(ExampleLoading());
    try {
      final items = await repository.fetchItems();
      emit(ExampleLoaded(items));
    } catch (e) {
      emit(ExampleFailure(e.toString()));
    }
  }
}
```

---

## ⚠️ Errores Comunes
1. **No liberar controladores:** Asegúrate de liberar siempre los `TextEditingController` o `ScrollController` utilizando `dispose()`.
2. **Hardcoding de URLs:** Nunca utilices URLs directas. Utiliza siempre la configuración global provista a través del cliente de red en `ApiClient`.
3. **No inmutabilidad en los estados:** Evita mutar los estados del BLoC directamente. Utiliza siempre subclases explícitas o métodos `copyWith` para emitir nuevos estados limpios.
