---
name: eventhub-api-tester
description: Validates rest endpoints, query parameters, jwt headers, and json responses between the mobile client and the go backend.
---

# Event Hub API Integration Tester

## Overview
Esta skill guía a los agentes y desarrolladores en la verificación del correcto acoplamiento y comunicación de red entre el cliente móvil Flutter (usando Dio) y el backend en Go (usando Gin). Previene incompatibilidades de endpoints, serialización de datos y autenticación de tokens.

---

## 📋 Lista de Verificación de Integración

### 1. Configuración de Red del Entorno (.env)
Asegura que el archivo `.env` en la raíz de Flutter esté configurado correctamente según la plataforma de prueba:
- **Emulador de Android local:** `API_BASE_URL=http://10.0.2.2:8080` (requerido para redirigir peticiones al localhost de la máquina hospedera).
- **Simulador de iOS o Web local:** `API_BASE_URL=http://localhost:8080`
- **Producción:** `API_BASE_URL=https://<domain_del_servidor>`

### 2. Validación de Rutas y Métodos
Cuando audites o verifiques un endpoint:
1. Compara el archivo `lib/core/utils/constants.dart` con las rutas registradas en el Router del backend en Go.
2. Comprueba que el método HTTP (GET, POST, PUT, DELETE) coincida de forma estricta.
3. Asegura que los parámetros de consulta (`queryParameters`) y el cuerpo de la petición (`data`) cumplan con los campos esperados por las estructuras (Structs) de entrada en Go.

### 3. Mapeo y Serialización JSON (CamelCase vs SnakeCase)
Dado que Go suele utilizar `snake_case` para JSON y Dart utiliza `camelCase` en sus atributos de clase:
- Verifica que los modelos de datos en Flutter utilicen adecuadamente la correspondencia mediante anotaciones o mapeo manual. Ejemplo:
  ```dart
  // En EventModel:
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] as String,
      cupoMaximo: json['max_capacity'] as int, // Mapeo de snake_case a camelCase
    );
  }
  ```
- Si detectas una incongruencia (ej. campos nulos al deserializar), revisa el modelo Go en el backend para confirmar la etiqueta `json:"field_name"`.

### 4. Cabeceras e Inyección de JWT
Todas las peticiones autenticadas deben enviar el JWT:
- El `ApiClient` lee de forma asíncrona `session_token` desde `FlutterSecureStorage` e inserta la cabecera `Authorization: Bearer <token>`.
- Si las peticiones fallan con error `401 Unauthorized`, valida que el token no haya expirado y que la cabecera esté inyectándose con el formato exacto `Bearer <JWT>`.

---

## ⚠️ Errores Comunes de Integración
1. **Utilizar `localhost` en el Emulador de Android:** Esto resulta en un fallo inmediato de conexión `SocketException: Connection refused`. Debe usarse `10.0.2.2`.
2. **Ignorar Cabeceras Set-Cookie:** Si el backend envía el JWT como una cookie segura en lugar de JSON, la app móvil debe extraer el valor de la cabecera `Set-Cookie` en el repositorio para guardarlo en el almacenamiento seguro.
3. **Mapeo de Tipos Incorrecto:** Convertir un entero (`int`) de JSON directamente a un double o viceversa sin un casteo seguro puede provocar caídas en tiempo de ejecución.
