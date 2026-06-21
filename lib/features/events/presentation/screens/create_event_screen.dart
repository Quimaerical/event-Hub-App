import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../dashboard/data/models/category_model.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime? _selectedDateTime;
  List<CategoryModel> _categoriesList = [];
  final List<int> _selectedCategoryIds = [];
  
  bool _isLoadingCategories = true;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get('/eventos/crear');
      
      final data = response.data as Map<String, dynamic>;
      final catsJson = data['categorias'] as List? ?? [];
      
      setState(() {
        _categoriesList = catsJson.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categoriesError = 'No se pudieron cargar las categorías';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date == null) return;
    
    if (!mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  void _generateAIDescription() {
    final title = _tituloController.text.trim();
    final location = _ubicacionController.text.trim();
    
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese el título y la ubicación para generar la sugerencia.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true); // Return success to trigger dashboard refresh
          } else if (state is GeminiSuggestionSuccess) {
            setState(() {
              _descripcionController.text = state.suggestion;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Descripción sugerida por Gemini insertada!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is EventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  controller: _tituloController,
                  validator: (val) => AppValidators.validateRequired(val, 'El título'),
                  decoration: const InputDecoration(
                    labelText: 'Título del Evento',
                    hintText: 'Ej. Taller Práctico de Clean Architecture',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Location
                TextFormField(
                  controller: _ubicacionController,
                  validator: (val) => AppValidators.validateRequired(val, 'La ubicación'),
                  decoration: const InputDecoration(
                    labelText: 'Ubicación o Enlace',
                    hintText: 'Ej. Auditorio Central o Link de Zoom',
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker trigger row
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg.withOpacity(0.5),
                      border: Border.all(color: AppTheme.borderDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'Seleccionar Fecha y Hora'
                              : 'Fecha: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}  Hora: ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _selectedDateTime == null ? AppTheme.textMuted : AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: AppTheme.primaryViolet),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories list section
                const Text(
                  'Categorías',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
                const SizedBox(height: 8),
                _isLoadingCategories
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryViolet))
                    : _categoriesError != null
                        ? Text(_categoriesError!, style: const TextStyle(color: Colors.redAccent))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categoriesList.map((category) {
                              final isSelected = _selectedCategoryIds.contains(category.id);
                              return FilterChip(
                                label: Text(category.nombre),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryViolet,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppTheme.cardBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primaryViolet : AppTheme.borderDark,
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

                // Description Title & Gemini Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Descripción del Evento',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    
                    // Gemini Suggestion Button
                    BlocBuilder<EventBloc, EventState>(
                      builder: (context, state) {
                        final generating = state is EventLoading;
                        return TextButton.icon(
                          onPressed: generating ? null : _generateAIDescription,
                          icon: const Icon(Icons.bolt, size: 16),
                          label: Text(generating ? 'Generando...' : 'Sugerir con Gemini IA'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryViolet,
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  validator: (val) => AppValidators.validateRequired(val, 'La descripción'),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos de qué se tratará este evento...',
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryViolet),
                      );
                    }
                    return ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Publicar Evento'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
