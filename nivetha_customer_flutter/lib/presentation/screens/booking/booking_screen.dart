
import 'package:flutter/material.dart';

import '../../../core/services/booking_service.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  final _formKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();
  final _personsController = TextEditingController(text: '100');
  final _notesController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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

  final List<String> _mealTypes = const [
    'Breakfast',
    'Lunch',
    'Dinner',
  ];

  final List<String> _foodTypes = const [
    'Veg',
    'Non-Veg',
    'Both',
  ];

  final List<String> _cateringTypes = const [
    'Cooking Service',
    'Serving Staff',
    'Both Services',
  ];

  String _eventType = 'Wedding';
  String _mealType = 'Lunch';
  String _foodType = 'Veg';
  String _cateringType = 'Both Services';

  DateTime? _eventDate;
  TimeOfDay? _eventTime;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    _personsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate != null &&
              _eventDate!.isAfter(now.subtract(const Duration(days: 1)))
          ? _eventDate!
          : now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
      helpText: 'Select function date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: navy,
              secondary: gold,
              surface: cream,
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

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Select function time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: navy,
              secondary: gold,
              surface: cream,
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

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null) {
      _showMessage('Please select the function date.');
      return;
    }

    if (_eventTime == null) {
      _showMessage('Please select the function time.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    final date = _eventDate!;
    final time = _eventTime!;

    final bookingData = <String, dynamic>{
      'eventType': _eventType,
      'eventDate':
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
      'eventTime':
          '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}',
      'location': _locationController.text.trim(),
      'numberOfPersons': int.parse(_personsController.text.trim()),
      'cateringType': _cateringType,
      'mealType': _mealType,
      'foodType': _foodType,
      'notes': _notesController.text.trim(),
    };

    try {
      final response = await BookingService.instance.createBooking(
        bookingData: bookingData,
      );

      if (!mounted) return;

      final responseData = response['booking'] is Map
          ? Map<String, dynamic>.from(response['booking'] as Map)
          : response;

      final bookingId = (
        responseData['_id'] ??
        responseData['id'] ??
        responseData['bookingId'] ??
        ''
      ).toString();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingId: bookingId,
            bookingData: bookingData,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Booking failed. Please check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: navy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroCard(),
                          const SizedBox(height: 25),
                          _sectionHeading(
                            'Event Details',
                            'உங்கள் விழா விவரங்கள்',
                            Icons.event_note_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildEventType(),
                          const SizedBox(height: 19),
                          _buildDateTimeFields(),
                          const SizedBox(height: 19),
                          _buildLocationField(),
                          const SizedBox(height: 19),
                          _buildPersonsField(),
                          const SizedBox(height: 28),
                          _sectionHeading(
                            'Catering Preferences',
                            'உணவு மற்றும் சேவை தேர்வுகள்',
                            Icons.restaurant_menu_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildMealType(),
                          const SizedBox(height: 19),
                          _buildFoodType(),
                          const SizedBox(height: 19),
                          _buildCateringType(),
                          const SizedBox(height: 19),
                          _buildNotesField(),
                          const SizedBox(height: 27),
                          _buildSubmitButton(),
                          const SizedBox(height: 14),
                          Text(
                            'Your booking will be submitted for confirmation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Colors.blueGrey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 22),
      child: Row(
        children: [
          _iconButton(
            Icons.arrow_back_rounded,
            () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Catering',
                  style: TextStyle(
                    color: navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plan your special occasion',
                  style: TextStyle(
                    color: Color(0xFF987022),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE6A2), gold],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE9DFD0)),
          ),
          child: Icon(icon, color: navy),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25496C), navy, Color(0xFF091629)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.17),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make it Memorable!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'சிறப்பான விழாவிற்கு சிறந்த உணவு',
                  style: TextStyle(
                    color: Color(0xFFFFE6A2),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.celebration_rounded,
            color: gold,
            size: 53,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.17),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: navy, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF987022),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventType() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Event Type', 'விழா வகை'),
          const SizedBox(height: 11),
          DropdownButtonFormField<String>(
            initialValue: _eventType,
            isExpanded: true,
            decoration: _inputDecoration(
              icon: Icons.celebration_outlined,
              hint: 'Select event type',
            ),
            items: _eventTypes.map((event) {
              return DropdownMenuItem<String>(
                value: event,
                child: Text(
                  event,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _eventType = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          child: _dateTimeCard(
            title: 'Function Date',
            subtitle: 'விழா தேதி',
            icon: Icons.calendar_today_rounded,
            value: _eventDate == null
                ? 'Select date'
                : '${_eventDate!.day.toString().padLeft(2, '0')}/'
                    '${_eventDate!.month.toString().padLeft(2, '0')}/'
                    '${_eventDate!.year}',
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dateTimeCard(
            title: 'Function Time',
            subtitle: 'விழா நேரம்',
            icon: Icons.access_time_rounded,
            value: _eventTime == null
                ? 'Select time'
                : _eventTime!.format(context),
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _dateTimeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE9DFD0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: gold, size: 23),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF987022),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: (_eventDate == null && title == 'Function Date') ||
                          (_eventTime == null && title == 'Function Time')
                      ? Colors.blueGrey.shade400
                      : navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Event Location', 'விழா நடைபெறும் இடம்'),
          const SizedBox(height: 11),
          TextFormField(
            controller: _locationController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              icon: Icons.location_on_outlined,
              hint: 'Enter event address',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the event location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonsField() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Number of Persons', 'எத்தனை நபர்கள்?'),
          const SizedBox(height: 11),
          TextFormField(
            controller: _personsController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              icon: Icons.groups_rounded,
              hint: 'Enter guest count',
            ),
            validator: (value) {
              final persons = int.tryParse(value?.trim() ?? '');

              if (persons == null || persons < 1) {
                return 'Enter a valid number of persons';
              }

              if (persons > 100000) {
                return 'Please enter a valid guest count';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealType() {
    return _optionSelector(
      title: 'Meal Session',
      subtitle: 'உணவு நேரம்',
      options: _mealTypes,
      selected: _mealType,
      icon: Icons.schedule_rounded,
      onSelected: (value) => setState(() => _mealType = value),
    );
  }

  Widget _buildFoodType() {
    return _optionSelector(
      title: 'Food Preference',
      subtitle: 'உணவு விருப்பம்',
      options: _foodTypes,
      selected: _foodType,
      icon: Icons.restaurant_rounded,
      onSelected: (value) => setState(() => _foodType = value),
    );
  }

  Widget _buildCateringType() {
    return _optionSelector(
      title: 'Catering Service',
      subtitle: 'சேவை தேர்வு',
      options: _cateringTypes,
      selected: _cateringType,
      icon: Icons.room_service_rounded,
      onSelected: (value) => setState(() => _cateringType = value),
    );
  }

  Widget _optionSelector({
    required String title,
    required String subtitle,
    required List<String> options,
    required String selected,
    required IconData icon,
    required ValueChanged<String> onSelected,
  }) {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(title, subtitle),
          const SizedBox(height: 13),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: options.map((option) {
              final isSelected = option == selected;

              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (_) => onSelected(option),
                avatar: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: Colors.white,
                      )
                    : Icon(icon, size: 16, color: navy),
                showCheckmark: false,
                backgroundColor: cream,
                selectedColor: navy,
                side: BorderSide(
                  color: isSelected ? navy : const Color(0xFFE8DECE),
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Extra Requirements', 'கூடுதல் தேவைகள்'),
          const SizedBox(height: 11),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              icon: Icons.edit_note_rounded,
              hint: 'Any special requests or instructions?',
            ).copyWith(
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE5A0),
            gold,
            Color(0xFFBB852C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: navy,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: navy,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'SUBMIT BOOKING',
                    style: TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF987022),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.blueGrey.shade300,
        fontSize: 12,
      ),
      prefixIcon: Icon(icon, color: gold, size: 22),
      filled: true,
      fillColor: cream,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE8DECE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: gold,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}
