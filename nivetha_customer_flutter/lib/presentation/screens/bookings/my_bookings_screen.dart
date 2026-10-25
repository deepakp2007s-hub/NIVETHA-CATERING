
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

const Color _cream = Color(0xFFFFF7E8);
const Color _gold = Color(0xFFC58B19);
const Color _brown = Color(0xFF45250E);
const Color _muted = Color(0xFF806D59);

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  static const Color _darkGold = Color(0xFF925D0B);

  final ApiService _api = ApiService.instance;
  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;

    return _bookings.where((booking) {
      final status = _normalizedStatus(booking['status']);
      if (_selectedFilter == 'Cancelled') {
        return status == 'cancelled' || status == 'rejected';
      }
      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  String _normalizedStatus(dynamic value) {
    final status = (value ?? 'Pending')
        .toString()
        .trim()
        .toLowerCase();

    if (status == 'canceled') return 'cancelled';
    return status.isEmpty ? 'pending' : status;
  }

  Color _statusColor(String status) {
    switch (_normalizedStatus(status)) {
      case 'confirmed':
        return const Color(0xFF21834A);
      case 'completed':
        return const Color(0xFF2469B3);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFC0392B);
      case 'pending':
      default:
        return _darkGold;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _api.get('bookings/my');

      if (!mounted) return;

      dynamic rawBookings;

      if (response is List) {
        rawBookings = response;
      } else if (response is Map) {
        rawBookings = response['bookings'] ??
            response['data'] ??
            response['results'];

        if (rawBookings is Map) {
          rawBookings = rawBookings['bookings'] ??
              rawBookings['data'] ??
              rawBookings['results'];
        }
      }

      if (rawBookings is! List) {
        throw Exception('Unexpected bookings response from server.');
      }

      final loadedBookings = rawBookings
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        _bookings = loadedBookings;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your bookings. Please try again.';
      });
    }
  }

  Future<void> _refreshBookings() async {
    await _loadBookings();
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Date not available';
    }

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _bookingId(Map<String, dynamic> booking) {
    return (booking['bookingId'] ??
            booking['_id'] ??
            booking['id'] ??
            'N/A')
        .toString();
  }

  String _eventType(Map<String, dynamic> booking) {
    return (booking['eventType'] ??
            booking['functionType'] ??
            'Catering Event')
        .toString();
  }

  String _location(Map<String, dynamic> booking) {
    return (booking['eventLocation'] ??
            booking['location'] ??
            booking['address'] ??
            'Not provided')
        .toString();
  }

  String _persons(Map<String, dynamic> booking) {
    return (booking['numberOfPersons'] ??
            booking['persons'] ??
            'N/A')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _brown,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh bookings',
            onPressed: _isLoading ? null : _refreshBookings,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _refreshBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            const Text(
              'Booking History',
              style: TextStyle(
                color: _brown,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 20),
            if (_isLoading)
              _buildLoading()
            else if (_errorMessage != null)
              _buildError()
            else if (bookings.isEmpty)
              _emptyState()
            else
              ...bookings.map(_bookingCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [_brown, Color(0xFF75451E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.receipt_long,
            color: _gold,
            size: 34,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Special Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Manage your catering bookings and check their status.',
            style: TextStyle(
              color: Color(0xFFF2E3CF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: _gold,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                '${_bookings.length} booking${_bookings.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            selectedColor: _gold,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : _brown,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: selected ? _gold : const Color(0xFFE8DCC8),
            ),
            onSelected: (_) {
              setState(() => _selectedFilter = filter);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 45),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: _gold),
          SizedBox(height: 16),
          Text(
            'Loading your bookings...',
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DCC8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: _darkGold,
            size: 48,
          ),
          const SizedBox(height: 14),
          const Text(
            'Could Not Load Bookings',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _brown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _loadBookings(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DCC8)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: _darkGold,
              size: 52,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedFilter == 'All'
                ? 'No Bookings Yet'
                : 'No $_selectedFilter Bookings',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _brown,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedFilter == 'All'
                ? 'Your catering bookings will appear here once you book an event.'
                : 'No ${_selectedFilter.toLowerCase()} bookings found.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _brown,
              side: const BorderSide(color: _gold),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? 'Pending').toString();
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DCC8)),
        boxShadow: [
          BoxShadow(
            color: _brown.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: _brown,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _eventType(booking),
                        style: const TextStyle(
                          color: _brown,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        'ID: ${_bookingId(booking)}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(color: Color(0xFFEFE4D3)),
            ),
            _detail(
              Icons.calendar_month_outlined,
              'Event Date',
              _formatDate(booking['eventDate'] ?? booking['date']),
            ),
            const SizedBox(height: 12),
            _detail(
              Icons.access_time_rounded,
              'Event Time',
              (booking['eventTime'] ?? 'Not provided').toString(),
            ),
            const SizedBox(height: 12),
            _detail(
              Icons.location_on_outlined,
              'Location',
              _location(booking),
            ),
            const SizedBox(height: 12),
            _detail(
              Icons.groups_outlined,
              'Guests',
              _persons(booking),
            ),
            if (booking['totalAmount'] != null ||
                booking['amount'] != null) ...[
              const SizedBox(height: 12),
              _detail(
                Icons.currency_rupee,
                'Amount',
                '₹${booking['totalAmount'] ?? booking['amount']}',
              ),
            ],
            if ((booking['extraRequirements'] ?? '')
                .toString()
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 12),
              _detail(
                Icons.notes_rounded,
                'Requirements',
                booking['extraRequirements'].toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _darkGold, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _brown,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
