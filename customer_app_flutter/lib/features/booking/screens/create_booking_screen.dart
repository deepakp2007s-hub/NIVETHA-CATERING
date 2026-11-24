import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/booking_service.dart';
import '../../menu/screens/menu_screen.dart';

/// Comprehensive event catering booking creation screen with warm royal maroon &
/// saffron gold catering design.
class CreateBookingScreen extends StatefulWidget {
  final List<FoodModel>? preSelectedFoods;

  const CreateBookingScreen({super.key, this.preSelectedFoods});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  static const Color _maroon = Color(0xFF6B1D2F);
  static const Color _maroonLight = Color(0xFF8E2940);
  static const Color _gold = Color(0xFFD49A3A);
  static const Color _cream = Color(0xFFFAF7F2);
  static const Color _cardTint = Color(0xFFFDFBF7);
  static const Color _borderTone = Color(0xFFE8DFD3);
  static const Color _charcoal = Color(0xFF1E1E1E);

  final _formKey = GlobalKey<FormState>();
  final _bookingService = BookingService();

  final _guestCountController = TextEditingController(text: '150');
  final _locationController = TextEditingController();
  final _specialRequirementsController = TextEditingController();

  String _functionType = 'Wedding';
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _eventTime = const TimeOfDay(hour: 12, minute: 30);

  bool _cateringServiceRequired = true;
  bool _cookingService = true;
  bool _servingStaffRequired = true;

  String _mealType = 'Lunch';
  String _foodPreference = 'Veg';

  final List<FoodModel> _selectedFoods = [];
  bool _isSubmitting = false;

  // These values must match the FastAPI BookingCreate literals exactly.
  final List<String> _functionTypes = [
    'Wedding',
    'Engagement',
    'Birthday',
    'House Function',
    'Corporate Event',
    'College/School Event',
    'Temple Function',
    'Other',
  ];

  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Multiple',
  ];

  final List<String> _foodPreferences = [
    'Veg',
    'Non-Veg',
    'Both',
  ];

  @override
  void initState() {
    super.initState();
    final preSelected = widget.preSelectedFoods;
    if (preSelected != null && preSelected.isNotEmpty) {
      // Backend rejects unavailable dishes, so never carry them in.
      _selectedFoods.addAll(preSelected.where((f) => f.isAvailable));
    }
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _locationController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate.isBefore(today) ? today : _eventDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _maroon,
              onPrimary: Colors.white,
              secondary: _gold,
              surface: _cream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _maroon,
              onPrimary: Colors.white,
              secondary: _gold,
              surface: _cream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _eventTime = picked);
    }
  }

  Future<void> _openMenuSelector() async {
    final result = await Navigator.push<List<FoodModel>>(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          selectionMode: true,
          initialSelectedIds: _selectedFoods.map((f) => f.id).toList(),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedFoods
          ..clear()
          ..addAll(result.where((f) => f.isAvailable));
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9E1B24),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFoods.isEmpty) {
      _showError('Please select at least 1 dish for the catering feast.');
      return;
    }

    if (_foodPreference == 'Veg' && _selectedFoods.any((f) => !f.isVegetarian)) {
      _showError(
        'Food preference is "Veg" but a non-veg dish is selected. '
        'Change the preference to "Both" or remove the non-veg dish.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final guestCount = int.parse(_guestCountController.text.trim());
      final timeStr = _formatTimeOfDay(_eventTime);
      final notes = _specialRequirementsController.text.trim();

      final booking = BookingModel(
        id: '',
        functionType: _functionType,
        eventDate: _eventDate,
        eventTime: timeStr,
        location: _locationController.text.trim(),
        personsCount: guestCount,
        cateringServiceRequired: _cateringServiceRequired,
        cookingService: _cookingService,
        servingStaffRequired: _servingStaffRequired,
        mealType: _mealType,
        foodPreference: _foodPreference,
        selectedFoods: _selectedFoods
            .map((f) => SelectedFoodItemModel(
                  foodId: f.id,
                  foodName: f.name,
                  category: f.category,
                ))
            .toList(),
        specialRequirements: notes.isNotEmpty ? notes : null,
        status: 'pending',
      );

      final created = await _bookingService.createBooking(booking);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _borderTone),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: _maroon,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Booking Request Received!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _charcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your request for ${_functionType.toLowerCase()} catering on ${created.formattedDate} has been registered. Our culinary team will review and confirm shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'View My Bookings',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/my-bookings');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_maroon, _maroonLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold, width: 0.8),
            ),
            child: const Text(
              'NIVETHA CATERING INVITATION',
              style: TextStyle(
                color: Color(0xFFFFE5B4),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Plan Your Celebration Feast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share your event details and dishes for our team to prepare.',
            style: TextStyle(
              color: Color(0xFFF6E6E9),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerBox({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _cardTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderTone),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _maroon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _charcoal,
                ),
              ),
            ),
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
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Catering Event',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBanner(),
                const SizedBox(height: 20),

                // Section 1: Event Information
                _buildSectionCard(
                  title: '1. Event & Occasion Details',
                  icon: Icons.event_available_rounded,
                  children: [
                    const Text(
                      'Function / Celebration Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _functionType,
                      dropdownColor: Colors.white,
                      decoration: _inputDecoration('Select function type'),
                      items: _functionTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _functionType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date & Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _pickerBox(
                                icon: Icons.calendar_today_rounded,
                                text: _formatDate(_eventDate),
                                onTap: _pickDate,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _pickerBox(
                                icon: Icons.access_time_rounded,
                                text: _formatTimeOfDay(_eventTime),
                                onTap: _pickTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Venue Address / Location',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 500,
                      decoration: _inputDecoration(
                        'e.g. Sri Rama Marriage Hall, T. Nagar, Chennai',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) {
                          return 'Please provide the venue address';
                        }
                        if (v.length < 5) {
                          return 'Please enter a complete venue address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 2: Capacity & Catering Options
                _buildSectionCard(
                  title: '2. Guests & Dining Preferences',
                  icon: Icons.groups_rounded,
                  children: [
                    const Text(
                      'Expected Number of Guests (Persons)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _guestCountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'e.g. 250',
                        prefixIcon: Icons.people_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter expected guest count';
                        }
                        final count = int.tryParse(value.trim());
                        if (count == null || count <= 0) {
                          return 'Please enter a valid guest count (min 1)';
                        }
                        if (count > 100000) {
                          return 'Guest count cannot exceed 100000';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [50, 100, 200, 350, 500, 1000].map((count) {
                          final isSelected =
                              _guestCountController.text.trim() ==
                                  count.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              backgroundColor: isSelected
                                  ? _maroon.withValues(alpha: 0.12)
                                  : _cardTint,
                              side: BorderSide(
                                color: isSelected ? _maroon : _borderTone,
                              ),
                              label: Text(
                                '$count guests',
                                style: TextStyle(
                                  color: isSelected ? _maroon : _charcoal,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _guestCountController.text = count.toString();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meal Type & Food Preference
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Meal Course',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _mealType,
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration(''),
                                items: _mealTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _mealType = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Food Preference',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _foodPreference,
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration(''),
                                items: _foodPreferences.map((pref) {
                                  return DropdownMenuItem(
                                    value: pref,
                                    child: Text(
                                      pref,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _foodPreference = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Services Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Full Catering Service (Setup, Tables, Vessels)',
                        style: TextStyle(fontSize: 13.5, color: _charcoal),
                      ),
                      value: _cateringServiceRequired,
                      activeThumbColor: _maroon,
                      activeTrackColor: _gold.withValues(alpha: 0.45),
                      onChanged: (val) =>
                          setState(() => _cateringServiceRequired = val),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Live Cooking Service at Venue',
                        style: TextStyle(fontSize: 13.5, color: _charcoal),
                      ),
                      value: _cookingService,
                      activeThumbColor: _maroon,
                      activeTrackColor: _gold.withValues(alpha: 0.45),
                      onChanged: (val) => setState(() => _cookingService = val),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Uniformed Serving Staff & Buffet Captains',
                        style: TextStyle(fontSize: 13.5, color: _charcoal),
                      ),
                      value: _servingStaffRequired,
                      activeThumbColor: _maroon,
                      activeTrackColor: _gold.withValues(alpha: 0.45),
                      onChanged: (val) =>
                          setState(() => _servingStaffRequired = val),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 3: Selected Catering Dishes
                _buildSectionCard(
                  title: '3. Catering Menu Items (${_selectedFoods.length})',
                  icon: Icons.restaurant_menu_rounded,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Selected Dishes for Feast',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _charcoal,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openMenuSelector,
                          style: TextButton.styleFrom(foregroundColor: _maroon),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Pick from Menu',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFoods.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _cream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _gold.withValues(alpha: 0.6)),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.restaurant_outlined,
                                color: _maroon,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No dishes selected yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Pick from Menu" above to choose dishes added by Nivetha Catering.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedFoods.map((food) {
                          return Chip(
                            backgroundColor: _cream,
                            side: const BorderSide(color: _borderTone),
                            avatar: Icon(
                              Icons.circle,
                              size: 10,
                              color: food.isVegetarian
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                            label: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _charcoal,
                              ),
                            ),
                            deleteIconColor: _maroon,
                            onDeleted: () {
                              setState(() {
                                _selectedFoods.removeWhere((f) => f.id == food.id);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 4: Special Instructions
                _buildSectionCard(
                  title: '4. Special Requests & Dietary Notes',
                  icon: Icons.notes_rounded,
                  children: [
                    TextFormField(
                      controller: _specialRequirementsController,
                      maxLines: 3,
                      maxLength: 2000,
                      decoration: _inputDecoration(
                        'e.g. Less spicy for children, Jain options for 20 guests, welcome drink setup...',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitBooking,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 22,
                                  color: _gold,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Submit Catering Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderTone),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: _maroon, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _charcoal,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: _borderTone),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: _maroon) : null,
      filled: true,
      fillColor: _cardTint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderTone),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderTone),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _maroon,
          width: 1.8,
        ),
      ),
    );
  }
}