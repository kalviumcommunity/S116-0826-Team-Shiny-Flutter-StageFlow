import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class CreateEditProductionScreen extends StatefulWidget {
  final String? prodId;

  const CreateEditProductionScreen({super.key, this.prodId});

  @override
  State<CreateEditProductionScreen> createState() =>
      _CreateEditProductionScreenState();
}

class _CreateEditProductionScreenState
    extends State<CreateEditProductionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImageFile;
  String? _existingImageUrl;
  bool _isLoadingData = false;
  String? _dateValidationError;

  bool get _isEditing => widget.prodId != null;

  @override
  void initState() {
    super.initState();
    _checkAccessAndLoad();
  }

  void _checkAccessAndLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.currentUser?.role != 'director') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Director access required.')),
        );
        context.pop();
        return;
      }

      if (_isEditing) {
        setState(() {
          _isLoadingData = true;
        });

        final prodVm = context.read<ProductionsViewModel>();
        final prod = await prodVm.getProduction(widget.prodId!);
        if (prod != null && mounted) {
          setState(() {
            _titleController.text = prod.title;
            _descriptionController.text = prod.description;
            _startDate = prod.startDate;
            _endDate = prod.endDate;
            _existingImageUrl = prod.imageURL;
            _isLoadingData = false;
          });
        } else if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _validateDates();
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? now),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _validateDates();
      });
    }
  }

  bool _validateDates() {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _dateValidationError = 'Both start and end dates are required.';
      });
      return false;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _dateValidationError = 'End date cannot be before start date.';
      });
      return false;
    }
    setState(() {
      _dateValidationError = null;
    });
    return true;
  }

  Future<void> _saveProduction() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (!_validateDates()) {
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final directorId = authViewModel.currentUser?.uid;
    if (directorId == null) {
      return;
    }

    final prodVm = context.read<ProductionsViewModel>();
    bool success = false;

    if (_isEditing) {
      success = await prodVm.updateProduction(
        prodId: widget.prodId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        newPosterFile: _selectedImageFile,
        existingImageURL: _existingImageUrl,
      );
    } else {
      success = await prodVm.createProduction(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        directorId: directorId,
        posterFile: _selectedImageFile,
      );
    }

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodVm = context.watch<ProductionsViewModel>();
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Production' : 'New Production'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (prodVm.errorMessage != null) ...[
                    ErrorBanner(
                      message: prodVm.errorMessage!,
                      isDismissible: false,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Poster Picker Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 160,
                        height: 210,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1.5,
                          ),
                          image: _selectedImageFile != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImageFile!),
                                  fit: BoxFit.cover,
                                )
                              : _existingImageUrl != null &&
                                      _existingImageUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_existingImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (_selectedImageFile == null &&
                                (_existingImageUrl == null ||
                                    _existingImageUrl!.isEmpty))
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: AppColors.textSubtle,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Poster',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCharcoal
                                        .withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Production Title *',
                      hintText: 'e.g. Hamlet, Wicked, The Crucible',
                    ),
                    validator: (val) {
                      if ((val ?? '').trim().isEmpty) {
                        return 'Title is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText:
                          'Synopsis, rehearsal notes, or director vision...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartDate,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              suffixIcon:
                                  Icon(Icons.calendar_today_rounded, size: 20),
                            ),
                            child: Text(
                              _startDate != null
                                  ? dateFormat.format(_startDate!)
                                  : 'Select',
                              style: TextStyle(
                                color: _startDate != null
                                    ? AppColors.textDark
                                    : AppColors.textSubtle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndDate,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date *',
                              suffixIcon:
                                  Icon(Icons.calendar_today_rounded, size: 20),
                            ),
                            child: Text(
                              _endDate != null
                                  ? dateFormat.format(_endDate!)
                                  : 'Select',
                              style: TextStyle(
                                color: _endDate != null
                                    ? AppColors.textDark
                                    : AppColors.textSubtle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_dateValidationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _dateValidationError!,
                      style: const TextStyle(
                        color: AppColors.conflictRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Save Action Button
                  PrimaryButton(
                    label: _isEditing ? 'Save Changes' : 'Create Production',
                    isLoading: prodVm.isLoading,
                    onPressed: _saveProduction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
