import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/production_provider.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart';

class CreateAuditionDialog extends StatefulWidget {
  final String? initialProductionId;

  const CreateAuditionDialog({super.key, this.initialProductionId});

  @override
  State<CreateAuditionDialog> createState() => _CreateAuditionDialogState();
}

class _CreateAuditionDialogState extends State<CreateAuditionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController(text: '3:00 PM – 6:00 PM');
  final _venueController = TextEditingController(text: 'Room 201');

  String? _selectedProductionId;
  DateTime _auditionDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _selectedProductionId = widget.initialProductionId ??
        context.read<ProductionProvider>().selectedProduction?.id;
    if (_selectedProductionId == null &&
        context.read<ProductionProvider>().productions.isNotEmpty) {
      _selectedProductionId =
          context.read<ProductionProvider>().productions.first.id;
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _auditionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _auditionDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductionId == null || _selectedProductionId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a production for this audition')),
      );
      return;
    }

    final prodProv = context.read<ProductionProvider>();
    final targetProd = prodProv.productions.firstWhere(
      (p) => p.id == _selectedProductionId,
      orElse: () => prodProv.productions.first,
    );

    // Set as selected if needed and create audition
    prodProv.selectProduction(targetProd);
    await prodProv.createAudition(
      date: _auditionDate,
      time: _timeController.text.trim(),
      venue: _venueController.text.trim(),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductionProvider>();
    final productions = prodProv.productions;

    return AlertDialog(
      title: const Text('Post New Audition'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (productions.length > 1) ...[
                DropdownButtonFormField<String>(
                  value: _selectedProductionId,
                  decoration: const InputDecoration(
                    labelText: 'Production',
                    prefixIcon: Icon(Icons.theater_comedy),
                  ),
                  items: productions.map((p) {
                    return DropdownMenuItem(value: p.id, child: Text(p.title));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProductionId = val),
                  validator: (v) => Validators.required(v, 'Please select a production'),
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Audition Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    AppDateUtils.formatDate(_auditionDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'e.g. 3:00 PM – 6:00 PM',
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (v) => Validators.required(v, 'Time is required'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue / Room',
                  hintText: 'e.g. Room 201, Black Box',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => Validators.required(v, 'Venue is required'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 42),
          ),
          child: const Text('Post Audition'),
        ),
      ],
    );
  }
}
