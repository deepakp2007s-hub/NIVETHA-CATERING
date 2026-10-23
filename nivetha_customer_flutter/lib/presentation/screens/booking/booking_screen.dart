
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/booking_service.dart';
import 'booking_confirmation_screen.dart';

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

  final List<String> _eventTypes = const [
    'Wedding',
    'Engagement',
    'Birthday',
    'House Function',
    'Corporate Event',
    'College / School Event',
    'Temple Function',
    'Other',
  ];

  final List<String> _mealOptions = const [
    'Breakfast',
    'Lunch',
    'Dinner',
  ];

  String? _selectedEventType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _foodPreference = 'Vegetarian';
  final Set<String> _selectedMeals = {'Lunch'};

  bool _cookingService = true;
  bool _servingStaff = false;
  bool _isSubmitting = false;

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

    final initialDate = _selectedDate != null &&
            !_selectedDate!.isBefore(today)
        ? _selectedDate!
        : today;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 3),
      helpText: 'Select function date',
    );

    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ??
          const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Select function time',
    );

    if (time != null && mounted) {
      setState(() => _selectedTime = time);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _toApiDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submitBooking() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedEventType == null) {
      _showMessage('Please select your event type.');
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Please select your function date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select your function time.');
      return;
    }

    if (_selectedMeals.isEmpty) {
      _showMessage('Please select at least one meal.');
      return;
    }

    final persons = int.tryParse(_personsController.text.trim());

    if (persons == null || persons < 1) {
      _showMessage('Enter a valid number of persons.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await BookingService.instance.createBooking(
        customerType: _selectedEventType!,
        functionDate: _toApiDate(_selectedDate!),
        functionTime: _formatTime(_selectedTime!),
        location: _locationController.text.trim(),
        numberOfPersons: persons,
        foodPreference: _foodPreference,
        meals: _mealOptions
            .where((meal) => _selectedMeals.contains(meal))
            .toList(),
        extraRequirements: _requirementsController.text.trim(),
        cookingService: _cookingService,
        servingStaff: _servingStaff,
      );

      if (!mounted) return;

      final dynamic bookingValue =
          response['booking'] ?? response['data'] ?? response;

      if (bookingValue is! Map) {
        _showMessage(
          'Booking response received, but the details are invalid.',
        );
        return;
      }

      final bookingData = Map<String, dynamic>.from(bookingValue);

      if (bookingData.isEmpty) {
        _showMessage('Booking details were missing from the response.');
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => BookingConfirmationScreen(
            booking: bookingData,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Catering'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryGreenDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _buildIntro(),
              const SizedBox(height: 24),
              _sectionTitle('1. Event Details'),
              const SizedBox(height: 13),
              _buildEventTypeField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTimeField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Function Location',
                hint: 'Enter complete event address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the function location.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _personsController,
                label: 'Number of Persons',
                hint: 'Example: 200',
                icon: Icons.groups_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final persons = int.tryParse(value?.trim() ?? '');
                  if (persons == null || persons < 1) {
                    return 'Enter at least 1 person.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 26),
              _sectionTitle('2. Food Preferences'),
              const SizedBox(height: 12),
              _buildFoodPreference(),
              const SizedBox(height: 18),
              _buildMealSelector(),
              const SizedBox(height: 26),
              _sectionTitle('3. Catering Services'),
              const SizedBox(height: 12),
              _buildServiceSwitch(
                title: 'Cooking Service',
                subtitle: 'Cooking arrangements for your event',
                icon: Icons.soup_kitchen_outlined,
                value: _cookingService,
                onChanged: (value) {
                  setState(() => _cookingService = value);
                },
              ),
              const SizedBox(height: 10),
              _buildServiceSwitch(
                title: 'Serving Staff',
                subtitle: 'Staff to serve food to your guests',
                icon: Icons.room_service_outlined,
                value: _servingStaff,
                onChanged: (value) {
                  setState(() => _servingStaff = value);
                },
              ),
              const SizedBox(height: 26),
              _sectionTitle('4. Extra Requirements'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _requirementsController,
                label: 'Additional Notes (Optional)',
                hint: 'Tell us about any special requirements',
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available_rounded),
                            SizedBox(width: 10),
                            Text(
                              'Submit Booking Request',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your request will be sent to the catering service for review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.55),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 37,
            color: AppColors.primary,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Special Event',
                  style: TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Enter your event details to send a booking request.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primaryGreenDark,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildEventTypeField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedEventType,
      isExpanded: true,
      decoration: _decoration(
        label: 'Event Type',
        icon: Icons.celebration_outlined,
      ),
      hint: const Text('Select your event'),
      items: _eventTypes
          .map(
            (event) => DropdownMenuItem<String>(
              value: event,
              child: Text(event),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _selectedEventType = value);
      },
      validator: (value) =>
          value == null ? 'Please select an event type.' : null,
    );
  }

  Widget _buildDateField() {
    return _pickerField(
      label: 'Function Date',
      value: _selectedDate == null
          ? 'Select function date'
          : _formatDate(_selectedDate!),
      icon: Icons.calendar_month_outlined,
      onTap: _selectDate,
    );
  }

  Widget _buildTimeField() {
    return _pickerField(
      label: 'Function Time',
      value: _selectedTime == null
          ? 'Select function time'
          : _formatTime(_selectedTime!),
      icon: Icons.access_time_rounded,
      onTap: _selectTime,
    );
  }

  Widget _pickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _decoration(label: label, icon: icon),
        child: Text(
          value,
          style: TextStyle(
            color: value.startsWith('Select')
                ? AppColors.textSecondary
                : AppColors.primaryGreenDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textCapitalization: TextCapitalization.sentences,
      decoration: _decoration(
        label: label,
        icon: icon,
      ).copyWith(
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildFoodPreference() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _preferenceOption(
              title: 'Vegetarian',
              icon: Icons.eco_outlined,
              selected: _foodPreference == 'Vegetarian',
              onTap: () {
                setState(() => _foodPreference = 'Vegetarian');
              },
            ),
          ),
          Expanded(
            child: _preferenceOption(
              title: 'Non-Veg',
              icon: Icons.dinner_dining_rounded,
              selected: _foodPreference == 'Non-Vegetarian',
              onTap: () {
                setState(() => _foodPreference = 'Non-Vegetarian');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _preferenceOption({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: selected
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? AppColors.primaryGreenDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Meals',
          style: TextStyle(
            color: AppColors.primaryGreenDark,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 9,
          runSpacing: 8,
          children: _mealOptions.map((meal) {
            final selected = _selectedMeals.contains(meal);

            return FilterChip(
              label: Text(meal),
              selected: selected,
              showCheckmark: true,
              avatar: Icon(
                meal == 'Breakfast'
                    ? Icons.free_breakfast_outlined
                    : meal == 'Lunch'
                        ? Icons.lunch_dining_outlined
                        : Icons.dinner_dining_outlined,
                size: 18,
              ),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedMeals.add(meal);
                  } else {
                    _selectedMeals.remove(meal);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.13),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primaryGreenDark
                    : AppColors.textSecondary,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.cardBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
