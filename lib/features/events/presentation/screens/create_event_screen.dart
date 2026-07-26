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

/// Alias for conventional naming
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
  List<CategoryModel> _categoriesList = [];
  final List<int> _selectedCategoryIds = [];

  bool _isLoadingCategories = true;
  String? _categoriesError;
  bool _isUploadingImage = false;

  final List<String> _locationPresets = const [
    'Auditorio Principal - Piso 1',
    'Sala de Conferencias B',
    'Laboratorio de Innovación Tech',
    'Espacio Abierto / Patio Central',
    'Enlace Virtual / Zoom Meeting',
  ];

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
      _selectedCategoryIds.addAll(e.categorias.map((c) => c.id));
    }
    _loadCategories();
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

  Future<void> _loadCategories() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get('/eventos/crear');

      final data = response.data as Map<String, dynamic>;
      final catsJson = data['categorias'] as List? ?? [];

      if (!mounted) return;

      setState(() {
        _categoriesList = catsJson
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'No se pudieron cargar las categorías';
        _isLoadingCategories = false;
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
    });
  }

  void _simulateImagePick() async {
    setState(() {
      _isUploadingImage = true;
    });

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

    if (_formKey.currentState?.validate() ?? false) {
      context.read<EventBloc>().add(
        CreateEventRequested(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          fecha: _selectedDateTime!,
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
              padding: const EdgeInsets.all(24.0),
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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 20),

                    // Location Dropdown & Input
                    const _FormInputLabel(label: 'ESPACIO / UBICACIÓN'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _locationPresets.contains(_ubicacionController.text)
                          ? _ubicacionController.text
                          : null,
                      items: _locationPresets.map((preset) {
                        return DropdownMenuItem(
                          value: preset,
                          child: Text(
                            preset,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _ubicacionController.text = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Seleccione un espacio o escriba abajo...',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ubicacionController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'La ubicación'),
                      decoration: const InputDecoration(
                        hintText: 'O ingrese una ubicación personalizada...',
                        prefixIcon: Icon(
                          Icons.edit_location_alt_outlined,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date & Time Picker
                    const _FormInputLabel(label: 'FECHA Y HORA DE INICIO'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          border: Border.all(color: AppTheme.borderDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateTime == null
                                  ? 'Seleccionar Fecha y Hora'
                                  : 'Fecha: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}  ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: _selectedDateTime == null
                                    ? AppTheme.textMuted
                                    : AppTheme.textLight,
                                fontSize: 14,
                                fontWeight: _selectedDateTime != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.skyBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 24),

                    // Multiple Categories FilterChips
                    const _FormInputLabel(label: 'CATEGORÍAS DE EVENTO'),
                    const SizedBox(height: 8),
                    _isLoadingCategories
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.skyBlue,
                            ),
                          )
                        : _categoriesError != null
                        ? Text(
                            _categoriesError!,
                            style: const TextStyle(color: Colors.redAccent),
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

                    // Description Label with Gemini IA Spark Button
                    _AiDescriptionHeader(onGenerateAI: _generateAIDescription),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descripcionController,
                      validator: (val) =>
                          AppValidators.validateRequired(val, 'La descripción'),
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe la agenda, ponentes y detalles del evento...',
                      ),
                    ),
                    const SizedBox(height: 32),

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
        height: 160,
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
                    size: 36,
                    color: AppTheme.skyBlue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seleccionar Imagen de Portada',
                    style: TextStyle(
                      fontSize: 13,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _FormInputLabel(label: 'DESCRIPCIÓN DEL EVENTO'),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            final isGenerating = state is EventLoading;
            return OutlinedButton.icon(
              onPressed: isGenerating ? null : onGenerateAI,
              icon: isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.skyBlue,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppTheme.skyBlue,
                    ),
              label: Text(
                isGenerating ? 'Generando...' : 'Sugerir con IA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.skyBlue,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.skyBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
