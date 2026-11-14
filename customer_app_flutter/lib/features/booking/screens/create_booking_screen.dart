import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/food_service.dart';
import '../../menu/screens/menu_screen.dart';

/// Comprehensive event catering booking creation screen.
class CreateBookingScreen extends StatefulWidget {
  final List<FoodModel>? preSelectedFoods;

  const CreateBookingScreen({super.key, this.preSelectedFoods});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingService = BookingService();
  final _foodService = FoodService();

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
    if (widget.preSelectedFoods != null && widget.preSelectedFoods!.isNotEmpty) {
      _selectedFoods.addAll(widget.preSelectedFoods!);
    } else {
      _loadDefaultDishes();
    }
  }

  Future<void> _loadDefaultDishes() async {
    try {
      final catalog = await _foodService.getFoods();
      if (mounted && catalog.isNotEmpty && _selectedFoods.isEmpty) {
        setState(() {
          // Pre-select 2 signature dishes for a great out-of-the-box experience
          _selectedFoods.addAll(catalog.take(2));
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _locationController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
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

    if (result != null) {
      setState(() {
        _selectedFoods.clear();
        _selectedFoods.addAll(result);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 dish for the catering feast.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final guestCount = int.parse(_guestCountController.text.trim());
      final timeStr = _formatTimeOfDay(_eventTime);

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
        specialRequirements: _specialRequirementsController.text.trim().isNotEmpty
            ? _specialRequirementsController.text.trim()
            : null,
        status: 'pending',
      );

      final created = await _bookingService.createBooking(booking);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Booking Request Received!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your request for ${_functionType.toLowerCase()} catering on ${created.formattedDate} has been registered. Our culinary manager will review and confirm shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, '/my-bookings');
                    },
                    child: const Text('View My Bookings'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Book Catering Event',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                // Section 1: Event Information
                _buildSectionCard(
                  title: '1. Event & Occasion Details',
                  icon: Icons.event_available_rounded,
                  children: [
                    // Function Type Dropdown
                    const Text(
                      'Function / Celebration Type',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _functionType,
                      decoration: _inputDecoration('Select function type'),
                      items: _functionTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _functionType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date & Time Pickers Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Date',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 18, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_eventDate.day}/${_eventDate.month}/${_eventDate.year}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
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
                                style:
                                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 18, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTimeOfDay(_eventTime),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Venue Address Field
                    const Text(
                      'Venue Address / Location',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        'e.g. Sri Rama Marriage Hall, T. Nagar, Chennai',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide the venue address';
                        }
                        if (value.trim().length < 5) {
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
                    // Guest Count Field
                    const Text(
                      'Expected Number of Guests (Persons)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    // Quick guest count chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [50, 100, 200, 350, 500, 1000].map((count) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text('$count guests'),
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

                    // Meal Type & Food Preference Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Meal Course',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _mealType,
                                decoration: _inputDecoration(''),
                                items: _mealTypes.map((type) {
                                  return DropdownMenuItem(
                                      value: type, child: Text(type));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _mealType = val);
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
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _foodPreference,
                                decoration: _inputDecoration(''),
                                items: _foodPreferences.map((pref) {
                                  return DropdownMenuItem(
                                      value: pref, child: Text(pref));
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

                    // Hospitality Service Options Switches
                    const Text(
                      'Services Required',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Full Catering Service (Setup, Tables, Vessels)'),
                      value: _cateringServiceRequired,
                      activeThumbColor: primaryColor,
                      onChanged: (val) =>
                          setState(() => _cateringServiceRequired = val),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Live Cooking Service at Venue'),
                      value: _cookingService,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => setState(() => _cookingService = val),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Uniformed Serving Staff & Buffet Captains'),
                      value: _servingStaffRequired,
                      activeThumbColor: primaryColor,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Dishes for Feast',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        TextButton.icon(
                          onPressed: _openMenuSelector,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Pick from Menu'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFoods.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.restaurant_outlined,
                                  color: primaryColor, size: 36),
                              const SizedBox(height: 8),
                              const Text(
                                'No dishes selected yet',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Pick from Menu" above to choose authentic dishes.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
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
                            avatar: Icon(
                              Icons.circle,
                              size: 10,
                              color: food.isVegetarian
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                            label: Text(
                              food.name,
                              style: const TextStyle(fontSize: 12),
                            ),
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
                      backgroundColor: primaryColor,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Submit Catering Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Theme.of(context).colorScheme.primary)
          : null,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.8,
        ),
      ),
    );
  }
}
