import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/food_service.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingService = BookingService();
  final _foodService = FoodService();

  final _guestCountController = TextEditingController();
  final _venueAddressController = TextEditingController();

  String _selectedEventType = 'Wedding';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  List<FoodModel> _availableFoods = [];
  final List<String> _selectedFoodIds = [];

  bool _isLoadingFoods = true;
  bool _isSubmitting = false;

  final List<String> _eventTypes = [
    'Wedding',
    'Reception',
    'Birthday Party',
    'Corporate Event',
    'Housewarming',
    'Other Event',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableFoods();
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _venueAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableFoods() async {
    try {
      final foods = await _foodService.getFoods();
      setState(() {
        _availableFoods = foods.where((f) => f.isAvailable).toList();
        _isLoadingFoods = false;
      });
    } catch (e) {
      setState(() => _isLoadingFoods = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final booking = BookingModel(
        id: '',
        eventType: _selectedEventType,
        eventDate: _selectedDate,
        guestCount: int.parse(_guestCountController.text.trim()),
        venueAddress: _venueAddressController.text.trim(),
        status: 'pending',
        selectedFoodIds: _selectedFoodIds,
      );

      await _bookingService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catering booking request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
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

    return Scaffold(
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
                DropdownButtonFormField<String>(
                  initialValue: _selectedEventType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    prefixIcon: Icon(Icons.event_available),
                    border: OutlineInputBorder(),
                  ),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedEventType = val);
                  },
                ),
                const SizedBox(height: 16),

                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: Colors.grey),
                    title: const Text('Event Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    trailing: TextButton(
                      onPressed: _selectDate,
                      child: const Text('Change'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _guestCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Guest Count',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Guest count is required';
                    final count = int.tryParse(val.trim());
                    if (count == null || count <= 0) return 'Enter a valid guest count';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _venueAddressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Full Venue Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Venue address is required';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Select Menu Items',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (_isLoadingFoods)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_availableFoods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No menu items available for selection.', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableFoods.length,
                    itemBuilder: (context, index) {
                      final food = _availableFoods[index];
                      final isSelected = _selectedFoodIds.contains(food.id);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(food.category.isNotEmpty ? food.category : food.description),
                        activeColor: theme.colorScheme.primary,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedFoodIds.add(food.id);
                            } else {
                              _selectedFoodIds.remove(food.id);
                            }
                          });
                        },
                      );
                    },
                  ),

                const SizedBox(height: 28),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Catering Request',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}