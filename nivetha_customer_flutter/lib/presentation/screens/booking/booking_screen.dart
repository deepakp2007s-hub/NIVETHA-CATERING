
import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';

const Color _cream = Color(0xFFFFF7E8);
const Color _gold = Color(0xFFC58B19);
const Color _brown = Color(0xFF45250E);
const Color _muted = Color(0xFF806D59);

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _personsController = TextEditingController();
  final _requirementsController = TextEditingController();

  final ApiService _api = ApiService.instance;

  String _eventType = 'Wedding';
  String _foodType = 'Vegetarian';
  String _mealType = 'Lunch';

  bool _cookingService = true;
  bool _servingStaff = true;
  bool _isSubmitting = false;

  DateTime? _eventDate;
  TimeOfDay? _eventTime;

  final List<String> _events = const [
    'Wedding',
    'Engagement',
    'Birthday',
    'House Function',
    'Corporate Event',
    'College / School Event',
    'Temple Function',
    'Other',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _personsController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _gold,
              onPrimary: Colors.white,
              surface: _cream,
              onSurface: _brown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _eventDate = selected);
    }
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _gold,
              onPrimary: Colors.white,
              surface: _cream,
              onSurface: _brown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _eventTime = selected);
    }
  }

  String _apiEventType() {
    switch (_eventType) {
      case 'Wedding':
        return 'Wedding';
      case 'Engagement':
        return 'Engagement';
      case 'Birthday':
        return 'Birthday Party';
      case 'House Function':
        return 'Housewarming (Grahapravesam)';
      case 'Corporate Event':
        return 'Corporate Event';
      default:
        return 'Other Function';
    }
  }

  String _formatApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatApiTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? const Color(0xFF247547) : _brown,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _submitBooking() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null || _eventTime == null) {
      _showMessage('Please select your event date and time.');
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_eventDate!.isBefore(today)) {
      _showMessage('Event date cannot be in the past.');
      return;
    }

    final persons = int.tryParse(_personsController.text.trim());

    if (persons == null || persons < 10 || persons > 100000) {
      _showMessage('Catering requires at least 10 persons.');
      return;
    }

    final services = <String>[];

    if (_cookingService) {
      services.add('Cooking Service');
    }

    if (_servingStaff) {
      services.add('Serving Staff');
    }

    final requirements = <String>[
      'Food preference: $_foodType',
      'Meal type: $_mealType',
      'Cooking service: ${_cookingService ? 'Required' : 'Not required'}',
      'Serving staff: ${_servingStaff ? 'Required' : 'Not required'}',
    ];

    final additionalRequirements = _requirementsController.text.trim();

    if (additionalRequirements.isNotEmpty) {
      requirements.add('Additional requirements: $additionalRequirements');
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _api.post(
        'bookings',
        body: {
          'eventType': _apiEventType(),
          'eventDate': _formatApiDate(_eventDate!),
          'eventTime': _formatApiTime(_eventTime!),
          'eventLocation': _locationController.text.trim(),
          'numberOfPersons': persons,
          'selectedFoods': <Map<String, dynamic>>[],
          'cateringServices': services,
          'extraRequirements': requirements.join('\n'),
        },
      );

      if (!mounted) return;

      final message = response['message']?.toString() ??
          'Your booking request has been submitted.';

      _showMessage(message, success: true);

      final booking = response['booking'];
      final bookingId = booking is Map
          ? booking['bookingId']?.toString()
          : null;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: _cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF247547),
              size: 56,
            ),
            title: const Text(
              'Booking Request Sent!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _brown,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your catering request has been received. '
                  'Nivetha Catering Service will review your request.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
                if (bookingId != null && bookingId.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SelectableText(
                    'Booking ID: $bookingId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _brown,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      var message = error.toString();

      message = message
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '');

      if (message.toLowerCase().contains('401') ||
          message.toLowerCase().contains('unauthorized')) {
        message = 'Please log in again to submit your booking.';
      } else if (message.toLowerCase().contains('socketexception') ||
          message.toLowerCase().contains('failed host lookup')) {
        message = 'Network unavailable. Please check your internet.';
      } else if (message.trim().isEmpty) {
        message = 'Unable to submit booking. Please try again.';
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _brown, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _muted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _choiceCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSubmitting ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? _gold.withValues(alpha: 0.13) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _gold : const Color(0xFFE8DCC8),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _brown : _muted, size: 25),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: _brown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSubmitting ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DCC8)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _gold, size: 23),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _brown,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: _muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _brown,
        elevation: 0,
        title: const Text(
          'Book Catering',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [_brown, Color(0xFF75451E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restaurant_menu, color: _gold, size: 34),
                  SizedBox(height: 12),
                  Text(
                    'Make Your Event Special',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Delicious food and exceptional service for every occasion.',
                    style: TextStyle(
                      color: Color(0xFFF2E3CF),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Choose Your Function', Icons.celebration),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.65,
              ),
              itemBuilder: (context, index) {
                final event = _events[index];
                const icons = <IconData>[
                  Icons.favorite,
                  Icons.volunteer_activism,
                  Icons.cake,
                  Icons.home,
                  Icons.business,
                  Icons.school,
                  Icons.temple_hindu,
                  Icons.event,
                ];

                return _choiceCard(
                  title: event,
                  icon: icons[index],
                  selected: _eventType == event,
                  onTap: () => setState(() => _eventType = event),
                );
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Event Details', Icons.event_note),
            Row(
              children: [
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.calendar_month,
                    title: 'Event Date',
                    value: _eventDate == null
                        ? 'Select date'
                        : '${_eventDate!.day.toString().padLeft(2, '0')}/'
                            '${_eventDate!.month.toString().padLeft(2, '0')}/'
                            '${_eventDate!.year}',
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.access_time,
                    title: 'Event Time',
                    value: _eventTime?.format(context) ?? 'Select time',
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _input(
              label: 'Event Location / Address',
              icon: Icons.location_on_outlined,
              controller: _locationController,
              hint: 'Enter complete event address',
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter your event location'
                      : null,
            ),
            const SizedBox(height: 15),
            _input(
              label: 'Number of Persons',
              icon: Icons.groups_outlined,
              controller: _personsController,
              hint: 'Minimum 10 persons',
              keyboardType: TextInputType.number,
              validator: (value) {
                final count = int.tryParse(value?.trim() ?? '');

                if (count == null || count < 10 || count > 100000) {
                  return 'Enter 10 to 100000 persons';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Food Preferences', Icons.restaurant),
            const Text(
              'Food Type',
              style: TextStyle(
                color: _brown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _choiceCard(
                    title: 'Vegetarian',
                    icon: Icons.eco,
                    selected: _foodType == 'Vegetarian',
                    onTap: () => setState(() => _foodType = 'Vegetarian'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _choiceCard(
                    title: 'Non-Vegetarian',
                    icon: Icons.dinner_dining,
                    selected: _foodType == 'Non-Vegetarian',
                    onTap: () => setState(() => _foodType = 'Non-Vegetarian'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Meal Type',
              style: TextStyle(
                color: _brown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['Breakfast', 'Lunch', 'Dinner'].map((meal) {
                return ChoiceChip(
                  label: Text(meal),
                  selected: _mealType == meal,
                  selectedColor: const Color(0xFFF0D79F),
                  onSelected: _isSubmitting
                      ? null
                      : (_) => setState(() => _mealType = meal),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8DCC8)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _cookingService,
                    activeThumbColor: _gold,
                    title: const Text(
                      'Cooking Service',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Professional cooking team'),
                    onChanged: _isSubmitting
                        ? null
                        : (value) =>
                            setState(() => _cookingService = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _servingStaff,
                    activeThumbColor: _gold,
                    title: const Text(
                      'Serving Staff',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Staff to serve your guests'),
                    onChanged: _isSubmitting
                        ? null
                        : (value) =>
                            setState(() => _servingStaff = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Special Requirements', Icons.edit_note),
            _input(
              label: 'Additional Requirements (Optional)',
              icon: Icons.notes,
              controller: _requirementsController,
              hint: 'Describe any special requests...',
              maxLines: 4,
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  disabledBackgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available),
                          SizedBox(width: 10),
                          Text(
                            'Submit Booking Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your booking will need confirmation from Nivetha Catering Service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
