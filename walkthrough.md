# Walkthrough de Inicialización del Proyecto: Event Hub Mobile (Flutter)

Este documento detalla la estructura inicial, la configuración de la arquitectura limpia, las capas de datos y presentación, y los mecanismos de seguridad integrados para la aplicación móvil **eventhubapp**.

---

## ✉️ Prompt Inicial del Usuario

> **Actúa como un Ingeniero de Software Principal y Arquitecto especialista en Flutter y Dart. Necesito inicializar y verificar el andamiaje del proyecto móvil "event-hub-app" utilizando Antigravity CLI. El sistema debe estructurarse bajo los principios de Arquitectura Limpia y segregación de responsabilidades, optimizado para consumir un backend en Go (Gin Framework) y gestionar sesiones seguras mediante OAuth.**
> 
> Genera el andamiaje y la configuración inicial bajo los siguientes parámetros técnicos estrictos:
> 
> **1. CONFIGURACIÓN DEL PROYECTO Y DEPENDENCIAS NÚCLEO:**
> - Project Name: event_hub_app
> - Org Name: com.eventhub
> - State Management: flutter_bloc o riverpod (Selecciona uno estructurado para desacoplar la UI de la lógica de negocio).
> - Dependencias de Red y Datos: dio (Para peticiones HTTP con interceptores avanzados), json_annotation y json_serializable (Para tipado fuerte y parseo eficiente de JSON).
> - Dependencias de Persistencia y Seguridad: flutter_secure_storage (Para almacenamiento seguro de tokens JWT/OAuth) y shared_preferences (Para caché local ligera).
> 
> **2. ESTRUCTURA DE DIRECTORIOS (ARQUITECTURA LIMPIA POR CAPAS):**
> Crea de forma estricta dentro de la carpeta `/lib` los siguientes directorios y archivos base estructurados:
> - `/core`: Configuración global inmutable.
>   * `/core/network`: `api_client.dart` (Cliente Dio configurado con BaseURL dinámica desde variables de entorno, timeouts y manejo de errores HTTP 401/500).
>   * `/core/theme`: `app_theme.dart` (Estilización global y paleta de colores coherente con Tailwind CSS del frontend web).
>   * `/core/utils`: Constantes y validadores de formularios.
> - `/features`: Segmentación por características funcionales del sistema:
>   * `/features/auth`: Módulo de autenticación social. Incluir subcarpetas `/data` (repositories, datasources para OAuth callback), `/domain` (usecases de login/logout) y `/presentation` (bloc/notifier, screens para login).
>   * `/features/dashboard`: Módulo de cartelera y búsquedas. Incluir lógica de presentación para la barra de búsqueda y filtros dinámicos por categorías mapeados desde la API de Go.
>   * `/features/events`: Detalle de eventos, lógica de inscripción controlando la capacidad del cupo máximo localmente y feedback.
> 
> **3. RESTRICCIONES DE CONFIGURACIÓN INICIAL (BOILERPLATE Y CLEAN CODE):**
> - Configurar soporte multi-entorno mediante archivos `.env` o Dart Defines para manejar las URLs de desarrollo (localhost) y producción (Render) de forma transparente.
> - Asegurar que todos los modelos de datos utilicen tipado estricto e inmutabilidad (`@immutable` o usando el paquete `freezed` si es compatible con la configuración del CLI).
> - Incluir un middleware o interceptor global en la capa de red que inyecte de forma automática el token de autenticación en las cabeceras de cada petición hacia el backend.
> 
> Por favor, genera la estructura completa de archivos y directorios con el andamiaje listo para Flutter, respetando las convenciones oficiales de la comunidad de Dart (Effective Dart). ademas agrega un nuevo walkthrough.md con la misma estructura pero en este directorio de flutter

---

## 🏗️ Arquitectura Limpia por Capas (Clean Architecture)

El código fuente dentro de `lib/` está organizado bajo los estrictos estándares de segregación de responsabilidades:

```text
lib/
├── core/
│   ├── network/
│   │   └── api_client.dart       # Cliente Dio con interceptores de autorización
│   ├── theme/
│   │   └── app_theme.dart        # Colores coherentes con el frontend web (Slate/Violet)
│   └── utils/
│       ├── constants.dart        # Configuración de URLs y llaves de almacenamiento
│       └── validators.dart       # Validadores estáticos para campos de formularios
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart  # Persistencia y autenticación contra la API
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart       # Interfaz abstracta del repositorio
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart   # BLoC de control de estados de sesión
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── login_screen.dart          # Formulario de Login y botones OAuth
│   │           └── register_screen.dart       # Formulario de Registro de usuario
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── category_model.dart        # Modelo inmutable de categorías
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── dashboard_bloc.dart   # Manejo de cartelera, búsquedas y categorías
│   │       │   ├── dashboard_event.dart
│   │       │   └── dashboard_state.dart
│   │       └── screens/
│   │           └── dashboard_screen.dart      # Vista principal de cartelera
│   └── events/
│       ├── data/
│       │   └── models/
│       │       └── event_model.dart           # Modelo inmutable de eventos
│       └── presentation/
│           ├── bloc/
│           │   ├── event_bloc.dart      # Creación de eventos, registros locales y Gemini IA
│           │   ├── event_event.dart
│           │   └── event_state.dart
│           └── screens/
│               ├── create_event_screen.dart   # Creación de eventos con Gemini
│               └── event_detail_screen.dart   # Detalle de evento con cupo límite
├── main.dart                                  # Configuración de BLoCs y puerta de autenticación
```

---

## 🔧 Componentes Técnicos Destacados

### 1. Interceptor de Autorización y Manejo Dinámico de Entorno (`api_client.dart`)
- **Variables de Entorno**: Configurado con `flutter_dotenv` cargando `.env`.
- **Mapeo Local de Emulador**: El archivo `.env` usa `http://10.0.2.2:8080` de manera que el emulador Android acceda limpiamente al servidor local en Go del equipo host.
- **Inyección Automática de Token**: El interceptor lee dinámicamente `session_token` de `FlutterSecureStorage` en cada request saliente y lo inyecta como cabecera `Authorization: Bearer <token>`.
- **Mapeo de Respuestas y Errores**: Dio atrapa las excepciones de red y las traduce a mensajes en español orientados al usuario.

### 2. Extracción Avanzada de Cookies en el Repositorio (`auth_repository_impl.dart`)
Dado que el backend en Go utiliza cookies seguras HTTPOnly (`session_token`), la aplicación móvil emula y complementa este comportamiento:
- El repositorio intercepta la cabecera de respuesta `Set-Cookie` al iniciar sesión.
- Procesa la cadena para extraer el parámetro `session_token`.
- Lo almacena de forma segura en `FlutterSecureStorage`, garantizando compatibilidad total con la lógica nativa del servidor Gin.

### 3. Modelos de Datos Estrictos e Inmutables
Tanto `CategoryModel` como `EventModel` están definidos con decoradores `@immutable`. Utilizan tipado estricto y serialización manual tipo `fromJson`/`toJson` libre de boilerplate excesivo y rápida de compilar. Cuentan con soporte `copyWith` para actualizaciones eficientes de estado sin mutabilidad directa.

### 4. Control de Cupo y Capacidad Local (`event_bloc.dart`)
La lógica de inscripción al evento realiza una validación local en `event_bloc.dart` contra la propiedad inmutable `cupoMaximo` del evento. Si la cantidad de inscritos alcanza este límite, el BLoC emite inmediatamente un estado `EventFailure` impidiendo la inscripción y mostrando el feedback correspondiente al usuario en la UI.

### 5. Asistente con IA de Gemini
La pantalla de creación de eventos posee un botón integrado con el backend que envía el título y la ubicación actual. Mediante la API de Go se invoca el servicio de Gemini para retornar una descripción creativa que rellena dinámicamente el cuadro de texto.
