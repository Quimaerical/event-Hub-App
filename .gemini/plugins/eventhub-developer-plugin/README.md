# Event Hub Developer Plugin 🚀

Este plugin de desarrollo provee un conjunto de herramientas, guías estructuradas (Skills) y subagentes diseñados para agilizar el desarrollo, mantenimiento y aseguramiento de calidad del cliente móvil Flutter y su integración con el backend de Go de **Event Hub**.

---

## 🛠️ Skills Incluidas

### 1. `flutter-clean-bloc-generator`
Genera el andamiaje de nuevos módulos o características funcionales (Features) de Flutter siguiendo Clean Architecture y el patrón BLoC de manera estricta.
- **Uso:** Pídele al asistente: *"Usa la skill flutter-clean-bloc-generator para crear la feature [nombre_feature]"*.
- **Estructura generada:** Capas de datos, dominio y presentación (BLoCs, Events, States, Screens, Repositories).

### 2. `eventhub-api-tester`
Procedimientos detallados y scripts para validar y testear endpoints, cookies de sesión, headers y mapeo de datos entre el cliente Flutter (Dio) y el backend Go (Gin).
- **Uso:** Pídele al asistente: *"Usa la skill eventhub-api-tester para verificar el endpoint [path_endpoint]"*.

---

## 🤖 Agente de QA: `eventhub-qa-agent`

Un subagente especializado enfocado en la calidad del código, pruebas unitarias/widgets y prevención de fugas de memoria.
- **Uso:** Pídele al asistente: *"Invoca al agente eventhub-qa-agent para auditar el archivo [ruta_archivo]"* o *"Usa el agente de QA para generar pruebas para [bloc/pantalla]"*.
- **Foco:** Liberación de controladores en `dispose()`, seguridad de nulos (Null Safety) y pruebas robustas.

---

## ✍️ Cómo Modificar y Extender este Plugin

### Directorio del Plugin
El plugin está ubicado en la carpeta de configuración de plugins de tu IDE, de manera relativa en:
`.gemini/config/plugins/eventhub-developer-plugin/`

### 1. Modificar Skills Existentes
Cada skill se encuentra en su propia carpeta bajo `skills/` y contiene un archivo `SKILL.md`.
- Para modificar la lógica o las directrices de una skill, edita directamente su archivo `SKILL.md`.
- Asegúrate de mantener la cabecera (frontmatter) de YAML al inicio del archivo:
  ```yaml
  ---
  name: nombre-de-la-skill
  description: Breve descripción de su funcionamiento
  ---
  ```

### 2. Modificar el Agente de QA
Las directrices, persona e instrucciones del agente de QA están definidas en:
`agents/eventhub-qa-agent/AGENT.md`
- Puedes editar su comportamiento, reglas de auditoría de memoria o alcance editando el archivo `AGENT.md`.
- El agente utiliza una cabecera YAML similar a la de las skills para definir su identidad.

### 3. Crear Nuevas Skills o Agentes
- **Para una nueva Skill:** Crea un subdirectorio en `skills/nueva-skill/` y escribe un archivo `SKILL.md` con su frontmatter YAML y el flujo de pasos detallado.
- **Para un nuevo Agente:** Crea un subdirectorio en `agents/nuevo-agente/` y añade un archivo `AGENT.md` (o `agent.json`) definiendo sus system instructions y alcance.
- **Actualización:** Una vez añadidos los archivos en las carpetas correspondientes, el IDE cargará automáticamente las nuevas capacidades en la siguiente sesión de chat.
