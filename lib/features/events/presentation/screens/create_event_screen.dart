import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../dashboard/data/models/category_model.dart';
import '../../data/models/event_model.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

typedef CreateEditView = CreateEventScreen;

class CreateEventScreen extends StatefulWidget {
  final EventModel? eventToEdit;

  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _cupoController = TextEditingController(text: '50');
  final _imagenUrlController = TextEditingController();

  DateTime? _selectedDateTime;
  DateTime? _selectedEndDateTime;

  List<CategoryModel> _categoriesList = [];
  final List<int> _selectedCategoryIds = [];

  List<Map<String, dynamic>> _espaciosList = [];
  int? _selectedEspacioId;

  bool _isLoadingMetadata = true;
  String? _metadataError;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      final e = widget.eventToEdit!;
      _tituloController.text = e.titulo;
      _ubicacionController.text = e.ubicacion;
      _descripcionController.text = e.descripcion;
      _cupoController.text = e.cupoMaximo.toString();
      _imagenUrlController.text = e.imagenUrl ?? '';
      _selectedDateTime = e.fecha;
      _selectedEndDateTime = e.fechaFin;
      _selectedCategoryIds.addAll(e.categorias.map((c) => c.id));
    }
    _loadMetadata();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    _cupoController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    setState(() => _isLoadingMetadata = true);
    try {
      final apiClient = context.read<ApiClient>();

      // Fetch categories & espacios concurrently
      final catsFuture = apiClient.get('/categorias');
      final espaciosFuture = apiClient.get('/espacios');

      final results = await Future.wait([catsFuture, espaciosFuture]);

      final catsRes = results[0];
      final espaciosRes = results[1];

      List<CategoryModel> loadedCats = [];
      if (catsRes is Map && catsRes['categorias'] is List) {
        loadedCats = (catsRes['categorias'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (catsRes is List) {
        loadedCats = catsRes
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      List<Map<String, dynamic>> loadedEspacios = [];
      if (espaciosRes is Map && espaciosRes['espacios'] is List) {
        loadedEspacios = List<Map<String, dynamic>>.from(
          espaciosRes['espacios'] as List,
        );
      } else if (espaciosRes is List) {
        loadedEspacios = List<Map<String, dynamic>>.from(espaciosRes);
      }

      if (!mounted) return;

      setState(() {
        _categoriesList = loadedCats;
        _espaciosList = loadedEspacios;
        if (_espaciosList.isNotEmpty && _selectedEspacioId == null) {
          _selectedEspacioId = _espaciosList.first['id'] as int?;
          if (_ubicacionController.text.isEmpty) {
            _ubicacionController.text =
                _espaciosList.first['nombre']?.toString() ?? '';
          }
        }
        _isLoadingMetadata = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metadataError =
            'No se pudieron cargar los espacios y categorías del servidor.';
        _isLoadingMetadata = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _selectedEndDateTime = _selectedDateTime!.add(const Duration(hours: 2));
    });
  }

  void _simulateImagePick() async {
    setState(() => _isUploadingImage = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _imagenUrlController.text =
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop';
      _isUploadingImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagen de portada seleccionada con éxito.'),
        backgroundColor: AppTheme.seaGreen,
      ),
    );
  }

  void _generateAIDescription() {
    final title = _tituloController.text.trim();
    final location = _ubicacionController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, ingrese el título y la ubicación para generar la sugerencia.',
          ),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    context.read<EventBloc>().add(
      SuggestDescriptionRequested(titulo: title, ubicacion: location),
    );
  }

  void _submit() {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione la fecha y hora del evento.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione al menos una categoría.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final capacity = int.tryParse(_cupoController.text.trim()) ?? 50;

    if (_formKey.currentState?.validate() ?? false) {
      context.read<EventBloc>().add(
        CreateEventRequested(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          espacioId: _selectedEspacioId ?? 1,
          fecha: _selectedDateTime!,
          fechaFin: _selectedEndDateTime,
          capacidadMaxima: capacity,
          ubicacion: _ubicacionController.text.trim(),
          categoryIds: _selectedCategoryIds,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Evento' : 'Crear Evento')),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.seaGreen,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is GeminiSuggestionSuccess) {
            setState(() {
              _descripcionController.text = state.suggestion;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Descripción generada con Gemini IA insertada!'),
                backgroundColor: AppTheme.seaGreen,
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Selector Field
                    _ImagePickerField(
                      imageUrl: _imagenUrlController.text,
                      isUploading: _isUploadingImage,
                      onPickImage: _simulateImagePick,
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    const _FormInputLabel(label: 'TÍTULO DEL EVENTO'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _tituloController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'El título'),
                      decoration: const InputDecoration(
                        hintText:
                            'Ej. Hackathon Anual de Inteligencia Artificial',
                        prefixIcon: Icon(
                          Icons.event_note,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dynamic Location / Espacio Dropdown & Custom Input
                    const _FormInputLabel(label: 'ESPACIO / UBICACIÓN'),
                    const SizedBox(height: 6),
                    _isLoadingMetadata
                        ? const LinearProgressIndicator(color: AppTheme.skyBlue)
                        : _espaciosList.isNotEmpty
                        ? DropdownButtonFormField<int>(
                            initialValue: _selectedEspacioId,
                            items: _espaciosList.map((espacio) {
                              final id = espacio['id'] as int;
                              final name =
                                  espacio['nombre']?.toString() ??
                                  'Espacio $id';
                              final tipo = espacio['tipo']?.toString() ?? '';
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  tipo.isNotEmpty ? '$name ($tipo)' : name,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedEspacioId = val;
                                  final match = _espaciosList.firstWhere(
                                    (e) => e['id'] == val,
                                    orElse: () => {},
                                  );
                                  if (match.isNotEmpty) {
                                    _ubicacionController.text =
                                        match['nombre']?.toString() ?? '';
                                  }
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Seleccione un espacio del campus...',
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ubicacionController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'La ubicación'),
                      decoration: const InputDecoration(
                        hintText: 'Ubicación o detalles específicos...',
                        prefixIcon: Icon(
                          Icons.edit_location_alt_outlined,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Date & Time Picker (Overflow Fixed with Flexible)
                    const _FormInputLabel(label: 'FECHA Y HORA DE INICIO'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          border: Border.all(color: AppTheme.borderDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.skyBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _selectedDateTime == null
                                    ? 'Seleccionar Fecha y Hora'
                                    : 'Fecha: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}  ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _selectedDateTime == null
                                      ? AppTheme.textMuted
                                      : AppTheme.textLight,
                                  fontSize: 13,
                                  fontWeight: _selectedDateTime != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Capacity Limit
                    const _FormInputLabel(label: 'CAPACIDAD MÁXIMA (CUPOS)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cupoController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Ingrese la capacidad máxima';
                        }
                        final num = int.tryParse(val);
                        if (num == null || num <= 0) {
                          return 'La capacidad debe ser un número mayor a 0';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Ej. 50',
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Categories FilterChips
                    const _FormInputLabel(label: 'CATEGORÍAS DE EVENTO'),
                    const SizedBox(height: 8),
                    _isLoadingMetadata
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.skyBlue,
                            ),
                          )
                        : _metadataError != null
                        ? Text(
                            _metadataError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categoriesList.map((category) {
                              final isSelected = _selectedCategoryIds.contains(
                                category.id,
                              );
                              return FilterChip(
                                label: Text(category.nombre),
                                selected: isSelected,
                                selectedColor: AppTheme.skyBlue,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppTheme.cardBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.skyBlue
                                        : AppTheme.borderDark,
                                  ),
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategoryIds.add(category.id);
                                    } else {
                                      _selectedCategoryIds.remove(category.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24),

                    // Responsive Description Header (Overflow Fixed)
                    _AiDescriptionHeader(onGenerateAI: _generateAIDescription),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descripcionController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'La descripción'),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe la agenda, ponentes y detalles del evento...',
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    BlocBuilder<EventBloc, EventState>(
                      builder: (context, state) {
                        final isLoading = state is EventLoading;
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.skyBlue,
                            ),
                          );
                        }
                        return ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            isEditing ? 'Guardar Cambios' : 'Publicar Evento',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormInputLabel extends StatelessWidget {
  final String label;

  const _FormInputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;

  const _ImagePickerField({
    required this.imageUrl,
    required this.isUploading,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onPickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
          image: imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: isUploading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.skyBlue),
              )
            : imageUrl.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: AppTheme.skyBlue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seleccionar Imagen de Portada',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class _AiDescriptionHeader extends StatelessWidget {
  final VoidCallback onGenerateAI;

  const _AiDescriptionHeader({required this.onGenerateAI});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _FormInputLabel(label: 'DESCRIPCIÓN DEL EVENTO')),
        const SizedBox(width: 8),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            final isGenerating = state is EventLoading;
            return OutlinedButton.icon(
              onPressed: isGenerating ? null : onGenerateAI,
              icon: isGenerating
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.skyBlue,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppTheme.skyBlue,
                    ),
              label: Text(
                isGenerating ? 'Generando...' : 'Sugerir con IA',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.skyBlue,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.skyBlue),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
