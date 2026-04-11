import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class ConfirmAvailabilityScreen extends StatefulWidget {
  const ConfirmAvailabilityScreen({super.key});

  @override
  State<ConfirmAvailabilityScreen> createState() => _ConfirmAvailabilityScreenState();
}

class _ConfirmAvailabilityScreenState extends State<ConfirmAvailabilityScreen> {
  DateTime? _from;
  DateTime? _to;
  bool _recurring = false;
  final List<bool> _days = List.filled(7, false);
  final _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  bool _submitted = false;

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) _from = picked;
      else _to = picked;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Set Availability')),
        body: _submitted
            ? _SuccessView(onDone: () => Navigator.pop(context))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Availability Period', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Set the dates and times you\'re available to interpret.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: _DateTile(label: 'From', date: _from, onTap: () => _pickDate(true))),
                        const SizedBox(width: 12),
                        Expanded(child: _DateTile(label: 'To', date: _to, onTap: () => _pickDate(false))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: _recurring,
                      onChanged: (v) => setState(() => _recurring = v),
                      title: const Text('Recurring weekly', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                      subtitle: const Text('Set availability that repeats each week'),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_recurring) ...[
                      const SizedBox(height: 16),
                      const Text('Available Days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) => GestureDetector(
                          onTap: () => setState(() => _days[i] = !_days[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _days[i] ? AppColors.primary : AppColors.inputFill,
                            ),
                            child: Center(
                              child: Text(
                                _dayLabels[i],
                                style: TextStyle(color: _days[i] ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                              ),
                            ),
                          ),
                        )),
                      ),
                    ],
                    const SizedBox(height: 36),
                    PrimaryButton(
                      label: 'Confirm Availability',
                      onPressed: _from == null || _to == null ? null : () => setState(() => _submitted = true),
                    ),
                  ],
                ),
              ),
      );
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                date == null ? 'Select' : '${date!.day}/${date!.month}/${date!.year}',
                style: TextStyle(fontWeight: FontWeight.w700, color: date == null ? AppColors.textSecondary : AppColors.textPrimary, fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
      );
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
            const SizedBox(height: 20),
            Text('Availability Set!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text('Your availability has been saved. Admin will assign requests accordingly.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Done', onPressed: onDone),
          ],
        ),
      );
}
