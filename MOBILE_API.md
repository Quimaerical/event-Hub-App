# Event Hub - Documentación Oficial de la API REST Mobile (v1)

Esta documentación describe todos los endpoints disponibles en el backend de **Event Hub** bajo el prefijo `/api/v1/` para ser consumidos por la **aplicación móvil construida en Flutter**.

---

## 🔑 Configuración de Autenticación & Encabezados

Todas las solicitudes a endpoints protegidos deben incluir el token Bearer JWT en el encabezado HTTP:

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Base URLs:
- **Producción (Vercel)**: `https://event-hub-back.vercel.app/api/v1`
- **Desarrollo Local**: `http://localhost:8080/api/v1`

---

## 📋 Catálogo de Endpoints RESTful

### 1. Autenticación & Usuario (`/api/v1/auth`)

#### `POST /api/v1/auth/login`
Inicia sesión con correo y contraseña.

* **Body JSON**:
  ```json
  {
    "email": "singingseba@proton.me",
    "password": "Enjoyer9-Decrease6-Huntsman1-Static2-Uncrushed6-Overpass3"
  }
  ```
* **Respuesta Exitosa (200 OK)**:
  ```json
  {
    "message": "Autenticación exitosa",
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "user": {
      "id": 1,
      "nombre": "Sebastian Super Admin",
      "email": "singingseba@proton.me",
      "role_id": 1,
      "role_nombre": "administrador",
      "departamento": "Administración Central",
      "telefono": "+584141234567"
    }
  }
  ```

#### `POST /api/v1/auth/register`
Registra una nueva cuenta de usuario.

* **Body JSON**:
  ```json
  {
    "nombre": "Carlos Estudiante",
    "email": "carlos@uc.edu.ve",
    "password": "Password123!",
    "departamento": "Computación",
    "telefono": "+584120001122"
  }
  ```
* **Respuesta Exitosa (201 Created)**: Retorna el `token` JWT y objeto `user`.

#### `POST /api/v1/auth/oauth-login`
Autentica o registra un usuario utilizando proveedor nativo OAuth (Google / GitHub).

* **Body JSON**:
  ```json
  {
    "provider": "google",
    "email": "usuario@gmail.com",
    "name": "Nombre Usuario",
    "provider_id": "google_oauth_id_string"
  }
  ```
* **Respuesta Exitosa (200 OK)**: Retorna el `token` JWT y objeto `user`.

#### `GET /api/v1/auth/me` *(Protegido)*
Devuelve los datos del perfil del usuario autenticado.

#### `POST /api/v1/auth/fcm-token` *(Protegido)*
Registra o actualiza el token de notificaciones push de Firebase FCM del dispositivo móvil.

* **Body JSON**:
  ```json
  {
    "fcm_token": "fcm_device_token_hash_string..."
  }
  ```

---

### 2. Eventos & Cartelera (`/api/v1/eventos`)

#### `GET /api/v1/eventos`
Consulta la cartelera con filtros y paginación.

* **Query Parameters**:
  * `search` (opcional): Filtro por texto en título o descripción.
  * `category_id` (opcional): ID numérico de categoría.
  * `estado` (opcional): `aprobado`, `programado`, `solicitado`, etc.
  * `page` (predeterminado: 1): Número de página.
  * `limit` (predeterminado: 12, máx: 50): Cantidad por página.

#### `GET /api/v1/eventos/:id`
Obtiene los detalles completos de un evento por ID.

#### `POST /api/v1/eventos` *(Protegido)*
Crea un nuevo evento. Soporta JSON o `multipart/form-data` con archivo de imagen cargado desde el dispositivo.

* **Form Fields / JSON Body**:
  * `titulo` (string, obligatorio)
  * `descripcion` (string, obligatorio)
  * `espacio_id` (int, obligatorio)
  * `fecha_inicio` (string RFC3339 / ISO: `2026-07-25T14:00:00Z`)
  * `fecha_fin` (string RFC3339 / ISO: `2026-07-25T18:00:00Z`)
  * `capacidad_maxima` (int, obligatorio)
  * `categorias` (array de enteros, ej: `[1, 2]`)
  * `imagen` (archivo de imagen opcional en multipart)

#### `POST /api/v1/eventos/:id/inscribir` *(Protegido)*
Inscribe al usuario autenticado en el evento y agenda automáticamente en Google Calendar.

#### `DELETE /api/v1/eventos/:id/inscribir` *(Protegido)*
Cancela la reserva de inscripción del usuario.

#### `GET /api/v1/eventos/:id/asistentes`
Devuelve la lista de participantes inscritos. Muestra los nombres públicamente para todos los usuarios y los correos/teléfonos completos para el creador y administradores.

#### `POST /api/v1/eventos/sugerir-descripcion` *(Protegido)*
Genera una descripción optimizada para el evento utilizando la Inteligencia Artificial de Google Gemini 1.5 Flash.

---

### 3. Mi Tablón & Perfil (`/api/v1/tablon` & `/api/v1/perfil`)

#### `GET /api/v1/tablon` *(Protegido)*
Retorna los eventos a los que se ha inscrito el usuario y los eventos organizados por él.

#### `PUT /api/v1/perfil` *(Protegido)*
Actualiza el departamento y teléfono del usuario.

#### `POST /api/v1/perfil/password` *(Protegido)*
Cambia la contraseña local del usuario.

#### `DELETE /api/v1/perfil` *(Protegido)*
Eliminación permanente de cuenta con confirmación (`"ELIMINAR"`).

---

### 4. Metadatos & Ubicaciones (`/api/v1/categorias` & `/api/v1/espacios`)

#### `GET /api/v1/categorias`
Lista todas las categorías de eventos activas.

#### `GET /api/v1/espacios`
Lista todas las ubicaciones y espacios disponibles (nombre, tipo, capacidad, ubicación física).

---

### 5. Administración (`/api/v1/admin`) *(Super Admin)*

#### `GET /api/v1/admin/usuarios`
Lista todos los usuarios del sistema.

#### `PATCH /api/v1/admin/usuarios/:id/role`
Actualiza el rol de un usuario (`role_id`: 1=Admin, 2=Aprobador, 3=Organizador, 4=Usuario).

#### `DELETE /api/v1/admin/usuarios/:id`
Elimina un usuario del sistema.

#### `POST /api/v1/admin/espacios`
Registra un nuevo espacio o ubicación para eventos en la base de datos.

---

## 🚦 Códigos de Estado HTTP y Estructura de Errores

Todos los errores retornan una estructura JSON uniforme:

```json
{
  "error": "Mensaje descriptivo de la falla"
}
```

* **`200 OK`**: Petición procesada exitosamente.
* **`201 Created`**: Recurso creado con éxito.
* **`400 Bad Request`**: Datos de solicitud o fechas inválidas.
* **`401 Unauthorized`**: Token JWT ausente o expirado.
* **`403 Forbidden`**: Acceso denegado por falta de rol.
* **`404 Not Found`**: Evento o recurso no encontrado.
* **`409 Conflict`**: Conflicto de horario de espacio u ocupación.
