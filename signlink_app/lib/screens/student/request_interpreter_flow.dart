import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

/// Multi-step interpreter request flow (steps 0-4).
class RequestInterpreterFlow extends StatefulWidget {
  final int initialStep;
  const RequestInterpreterFlow({super.key, this.initialStep = 0});

  @override
  State<RequestInterpreterFlow> createState() => _RequestInterpreterFlowState();
}

class _RequestInterpreterFlowState extends State<RequestInterpreterFlow> {
  late int _step;
  bool _submitting = false;

  // Form data collected across steps
  String _requestType = '';
  String _eventTitle = '';
  String _location = '';
  DateTime? _date;
  TimeOfDay? _timeOfDay;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }

  bool _isStepValid() {
    switch (_step) {
      case 0: return _requestType.isNotEmpty;
      case 1: return _eventTitle.trim().isNotEmpty && _location.trim().isNotEmpty;
      case 2: return _date != null && _timeOfDay != null;
      default: return true;
    }
  }

  void _next() {
    if (_step == 3) {
      _submitRequest();
      return;
    }
    if (_step < 4) setState(() => _step++);
    else Navigator.pushNamedAndRemoveUntil(context, AppRoutes.studentDashboard, (r) => false);
  }

  Future<void> _submitRequest() async {
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final schedule = context.read<ScheduleProvider>();
    final requestDateTime = DateTime(
      _date!.year, _date!.month, _date!.day,
      _timeOfDay!.hour, _timeOfDay!.minute,
    );
    final ok = await schedule.submitRequest(
      studentId: auth.currentUser?.id ?? '',
      courseName: _eventTitle,
      location: _location,
      date: _date!,
      time: requestDateTime,
      requestType: _requestType.isEmpty ? 'class' : _requestType,
      notes: _notes.isEmpty ? null : _notes,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      setState(() => _step++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit request. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
    else Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Request Type', 'Event Details', 'Date & Time', 'Review', 'Done'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_step < 4 ? 'Request Interpreter' : 'Request Sent'),
        leading: _step < 4 ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _back) : null,
      ),
      body: Column(
        children: [
          if (_step < 4) _StepIndicator(current: _step, steps: steps.take(4).toList()),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IndexedStack(
                key: ValueKey(_step),
                index: _step,
                children: [
                  _StepRequestType(selected: _requestType, onSelect: (v) => setState(() => _requestType = v)),
                  _StepEventDetails(
                    title: _eventTitle, location: _location, notes: _notes,
                    onTitle: (v) => setState(() => _eventTitle = v),
                    onLocation: (v) => setState(() => _location = v),
                    onNotes: (v) => setState(() => _notes = v),
                  ),
                  _StepDateTime(
                    date: _date, timeOfDay: _timeOfDay,
                    onDate: (v) => setState(() => _date = v),
                    onTime: (v) => setState(() => _timeOfDay = v),
                  ),
                  _StepReview(type: _requestType, title: _eventTitle, location: _location, date: _date, timeOfDay: _timeOfDay, notes: _notes),
                  _StepSuccess(
                    eventTitle: _eventTitle,
                    location: _location,
                    date: _date,
                    timeOfDay: _timeOfDay,
                    requestType: _requestType,
                  ),
                ],
              ),
            ),
          ),
          if (_step < 4)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: PrimaryButton(
                label: _step == 3 ? 'Submit Request' : 'Continue',
                onPressed: (_isStepValid() && !_submitting) ? _next : null,
                isLoading: _step == 3 && _submitting,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> steps;
  const _StepIndicator({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: steps.asMap().entries.map((e) {
            final done = e.key < current;
            final active = e.key == current;
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.success : active ? AppColors.primary : AppColors.inputFill,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : Text('${e.key + 1}', style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (e.key < steps.length - 1)
                    Expanded(
                      child: Container(height: 2, color: done ? AppColors.success : AppColors.inputFill),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
}

class _StepRequestType extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _StepRequestType({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final types = [
      {'value': 'class', 'label': 'Class / Lecture', 'icon': Icons.class_rounded, 'desc': 'Request an interpreter for a specific class or lecture'},
      {'value': 'event', 'label': 'Campus Event', 'icon': Icons.event_rounded, 'desc': 'Departmental events, workshops, or seminars'},
      {'value': 'meeting', 'label': 'Meeting', 'icon': Icons.people_rounded, 'desc': 'Office hours, group meetings, or consultations'},
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      children: [
        Text('What type of request?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Select the type of interpretation service you need.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ...types.map((t) {
          final isSelected = selected == t['value'];
          return GestureDetector(
            onTap: () => onSelect(t['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(t['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['label'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary, fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text(t['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StepEventDetails extends StatelessWidget {
  final String title, location, notes;
  final ValueChanged<String> onTitle, onLocation, onNotes;
  const _StepEventDetails({required this.title, required this.location, required this.notes, required this.onTitle, required this.onLocation, required this.onNotes});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        children: [
          Text('Event Details', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: title,
            onChanged: onTitle,
            decoration: const InputDecoration(labelText: 'Event / Course Title', prefixIcon: Icon(Icons.title_rounded)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: location,
            onChanged: onLocation,
            decoration: const InputDecoration(labelText: 'Location / Venue', prefixIcon: Icon(Icons.location_on_rounded)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: notes,
            onChanged: onNotes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Additional Notes (optional)', alignLabelWithHint: true, prefixIcon: Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.notes_rounded))),
          ),
        ],
      );
}

class _StepDateTime extends StatelessWidget {
  final DateTime? date;
  final TimeOfDay? timeOfDay;
  final ValueChanged<DateTime?> onDate;
  final ValueChanged<TimeOfDay?> onTime;
  const _StepDateTime({required this.date, required this.timeOfDay, required this.onDate, required this.onTime});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        children: [
          Text('Date & Time', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              onDate(picked);
            },
            child: _PickerTile(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: date == null ? 'Select a date' : '${date!.day}/${date!.month}/${date!.year}',
              isPlaceholder: date == null,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (picked != null) onTime(picked);
            },
            child: _PickerTile(
              icon: Icons.access_time_rounded,
              label: 'Start Time',
              value: timeOfDay == null ? 'Select a time' : timeOfDay!.format(context),
              isPlaceholder: timeOfDay == null,
            ),
          ),
        ],
      );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;
  const _PickerTile({required this.icon, required this.label, required this.value, required this.isPlaceholder});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: isPlaceholder ? AppColors.textSecondary : AppColors.textPrimary, fontFamily: 'Inter')),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      );
}

class _StepReview extends StatelessWidget {
  final String type, title, location, notes;
  final DateTime? date;
  final TimeOfDay? timeOfDay;
  const _StepReview({required this.type, required this.title, required this.location, required this.date, required this.timeOfDay, required this.notes});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        children: [
          Text('Review & Submit', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Please verify your request details before submitting.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _ReviewRow(label: 'Request Type', value: type.isEmpty ? '—' : type),
          _ReviewRow(label: 'Title', value: title.isEmpty ? '—' : title),
          _ReviewRow(label: 'Location', value: location.isEmpty ? '—' : location),
          _ReviewRow(label: 'Date', value: date == null ? '—' : '${date!.day}/${date!.month}/${date!.year}'),
          _ReviewRow(label: 'Time', value: timeOfDay == null ? '—' : timeOfDay!.format(context)),
          if (notes.isNotEmpty) _ReviewRow(label: 'Notes', value: notes),
        ],
      );
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13))),
          ],
        ),
      );
}

class _StepSuccess extends StatelessWidget {
  final String eventTitle;
  final String location;
  final DateTime? date;
  final TimeOfDay? timeOfDay;
  final String requestType;

  const _StepSuccess({
    required this.eventTitle,
    required this.location,
    required this.date,
    required this.timeOfDay,
    required this.requestType,
  });

  DateTime? get _sessionDateTime {
    if (date == null) return null;
    if (timeOfDay == null) return date;
    return DateTime(date!.year, date!.month, date!.day, timeOfDay!.hour, timeOfDay!.minute);
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final start = _sessionDateTime ?? DateTime.now().add(const Duration(days: 1));
    final event = Event(
      title: 'SignLink: ${eventTitle.isEmpty ? requestType : eventTitle}',
      description: 'Sign Language Interpretation service – $requestType',
      location: location,
      startDate: start,
      endDate: start.add(const Duration(hours: 1)),
      allDay: false,
    );
    try {
      final added = await Add2Calendar.addEvent2Cal(event);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? 'Event added to calendar!' : 'Could not open calendar app.'),
          backgroundColor: added ? AppColors.success : AppColors.error,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No calendar app found on this device.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _setReminder(BuildContext context) async {
    final sessionDT = _sessionDateTime;
    if (sessionDT == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a date and time to set a reminder.')),
      );
      return;
    }
    final granted = await NotificationService.requestPermissions();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission denied.')),
        );
      }
      return;
    }
    await NotificationService.scheduleSessionReminder(
      id: sessionDT.millisecondsSinceEpoch ~/ 1000,
      sessionTitle: eventTitle.isEmpty ? requestType : eventTitle,
      sessionTime: sessionDT,
      location: location,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder set for 15 minutes before your session.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.success),
            const SizedBox(height: 24),
            Text('Request Submitted!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Your interpreter request has been submitted. You\'ll be notified once an interpreter is assigned.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _addToCalendar(context),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Add to Calendar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _setReminder(context),
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Set 15-min Reminder'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Back to Dashboard',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.studentDashboard, (r) => false),
            ),
          ],
        ),
      );
}
