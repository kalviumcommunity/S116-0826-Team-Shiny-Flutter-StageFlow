import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/production.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart';

class CreateEditProductionScreen extends StatefulWidget {
  final Production? production;

  const CreateEditProductionScreen({super.key, this.production});

  @override
  State<CreateEditProductionScreen> createState() => _CreateEditProductionScreenState();
}

class _CreateEditProductionScreenState extends State<CreateEditProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _startDate;
  late DateTime _endDate;
  XFile? _selectedImage;
  final StorageService _storageService = StorageService();

  bool get isEditing => widget.production != null;

  @override
  void initState() {
    super.initState();
    if (widget.production != null) {
      _titleController.text = widget.production!.title;
      _descriptionController.text = widget.production!.description;
      _startDate = widget.production!.startDate;
      _endDate = widget.production!.endDate;
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 60));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _storageService.pickPosterImage();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (!Validators.isProductionDatesValid(_startDate, _endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be on or after start date.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final prodProv = context.read<ProductionProvider>();

    bool success;
    if (isEditing) {
      final updated = widget.production!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
      success = await prodProv.updateProduction(
        production: updated,
        newPosterImage: _selectedImage,
      );
    } else {
      success = await prodProv.createProduction(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        directorId: auth.currentUser!.id,
        posterImage: _selectedImage,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Production updated!' : 'Production created!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      context.pop();
    } else if (mounted && prodProv.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prodProv.errorMessage!),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Production' : 'New Production'),
        actions: [
          TextButton(
            onPressed: prodProv.isLoading ? null : _handleSave,
            child: prodProv.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image Picker Box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPosterPreview(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: Text(_selectedImage != null || (isEditing && widget.production?.imageURL != null)
                      ? 'Change Poster Image'
                      : 'Upload Poster Image'),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Production Title (e.g. Hamlet)',
                  prefixIcon: Icon(Icons.theater_comedy),
                ),
                validator: (v) => Validators.required(v, 'Please enter a production title'),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description / Play synopsis',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Dates Row
              const Text(
                'Production Run Dates',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Opening / Start',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          AppDateUtils.formatDate(_startDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Closing / End',
                          prefixIcon: Icon(Icons.calendar_month, size: 18),
                        ),
                        child: Text(
                          AppDateUtils.formatDate(_endDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (prodProv.isUploadingPoster) ...[
                LinearProgressIndicator(value: prodProv.uploadProgress),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Uploading poster image... ${(prodProv.uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterPreview() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return Image.network(_selectedImage!.path, fit: BoxFit.cover);
      } else {
        return Image.file(File(_selectedImage!.path), fit: BoxFit.cover);
      }
    }
    if (isEditing && widget.production?.imageURL != null && widget.production!.imageURL!.isNotEmpty) {
      return Image.network(
        widget.production!.imageURL!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.black38),
          SizedBox(height: 6),
          Text(
            'Select Production Poster',
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
