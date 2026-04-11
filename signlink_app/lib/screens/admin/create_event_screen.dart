import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '100');
  DateTime? _date;
  bool _created = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    final success = await context.read<EventProvider>().createEvent(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      date: _date!,
      capacity: int.tryParse(_capacityCtrl.text) ?? 100,
      createdBy: context.read<AuthProvider>().currentUser?.id ?? '',
    );
    if (mounted && success) setState(() => _created = true);
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>();
    if (_created) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.success),
                  const SizedBox(height: 24),
                  Text('Event Created!', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text('"${_titleCtrl.text}" has been published and is now visible to students.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  PrimaryButton(label: 'Back to Dashboard', onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Event title is required' : null,
                decoration: const InputDecoration(labelText: 'Event Title', prefixIcon: Icon(Icons.event_rounded)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_rounded)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
                decoration: const InputDecoration(labelText: 'Location / Venue', prefixIcon: Icon(Icons.location_on_rounded)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Enter a valid number' : null,
                decoration: const InputDecoration(labelText: 'Capacity (attendees)', prefixIcon: Icon(Icons.people_rounded)),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Event Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            _date == null ? 'Select a date' : '${_date!.day}/${_date!.month}/${_date!.year}',
                            style: TextStyle(fontWeight: FontWeight.w700, color: _date == null ? AppColors.textSecondary : AppColors.textPrimary, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Publish Event', onPressed: _submit, isLoading: events.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
