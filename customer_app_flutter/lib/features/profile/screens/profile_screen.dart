import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/profile_service.dart';

/// Customer profile screen showing personal details, catering navigation,
/// and message-only support styled in the Forest Emerald & Warm Champagne Gold theme.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Forest Emerald & Warm Champagne Gold Palette
  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _deepForest = Color(0xFF0C2E24);
  static const Color _champagneGold = Color(0xFFD9A441);
  static const Color _softIvory = Color(0xFFFBF9F5);
  static const Color _warmSandBorder = Color(0xFFE5DEC9);
  static const Color _inkDark = Color(0xFF1A2421);
  static const Color _inkMuted = Color(0xFF5A6863);
  static const Color _warmAmber = Color(0xFFB46916);

  static const String _supportPhoneDisplay = '+91 88076 69855';
  static const String _supportPhoneNumber = '918807669855';

  final ProfileService _profileService = ProfileService();

  late Future<CustomerModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _profileService.getProfile();
    });
  }

  Future<void> _messageSupport() async {
    const prefilledText =
        'Hello Nivetha Catering, I need help with my profile / event booking.';
    final smsUri = Uri(
      scheme: 'sms',
      path: '+$_supportPhoneNumber',
      queryParameters: {'body': prefilledText},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message us at: $_supportPhoneDisplay'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog(CustomerModel customer) async {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _warmSandBorder),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w800, color: _inkDark),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _inkDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: _forestEmerald,
                    ),
                    filled: true,
                    fillColor: _softIvory,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _warmSandBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _warmSandBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: _forestEmerald,
                        width: 1.6,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _inkDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: _forestEmerald,
                    ),
                    filled: true,
                    fillColor: _softIvory,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _warmSandBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _warmSandBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: _forestEmerald,
                        width: 1.6,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: _inkMuted, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      try {
                        await _profileService.updateProfile(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                        );
                        if (!ctx.mounted || !mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: _forestEmerald,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _loadProfile();
                      } catch (e) {
                        if (!ctx.mounted || !mounted) return;
                        setDialogState(() => isSaving = false);
                        final errorMsg =
                            e.toString().replaceAll('Exception: ', '');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: const Color(0xFFC62828),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
      backgroundColor: _softIvory,
      appBar: AppBar(
        backgroundColor: _forestEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Customer Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: _champagneGold),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: FutureBuilder<CustomerModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _forestEmerald),
            );
          }

          if (snapshot.hasError) {
            final errorMsg =
                snapshot.error.toString().replaceAll('Exception: ', '');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Color(0xFFC62828),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load profile.\n$errorMsg',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFC62828)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestEmerald,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final customer = snapshot.data ??
              CustomerModel(
                id: '',
                name: 'Valued Customer',
                email: 'customer@example.com',
                phone: _supportPhoneDisplay,
              );

          return RefreshIndicator(
            color: _forestEmerald,
            backgroundColor: Colors.white,
            onRefresh: () async => _loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Avatar & Identity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _warmSandBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: _deepForest.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_forestEmerald, Color(0xFF1E634D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: _champagneGold,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _deepForest.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  customer.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 28,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: _champagneGold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: _deepForest,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _inkDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _inkMuted,
                          ),
                        ),
                        if (customer.phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            customer.phone,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _inkMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _forestEmerald,
                            backgroundColor: _softIvory,
                            side: const BorderSide(color: _forestEmerald),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showEditProfileDialog(customer),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text(
                            'Edit Profile Details',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Catering Navigation Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _warmSandBorder, width: 1.1),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          icon: Icons.calendar_month_rounded,
                          iconColor: _forestEmerald,
                          title: 'My Catering Bookings',
                          subtitle: 'Check confirmation status and event menus',
                          onTap: () =>
                              Navigator.pushNamed(context, '/my-bookings'),
                        ),
                        const Divider(height: 1, color: _warmSandBorder),
                        _buildProfileTile(
                          icon: Icons.restaurant_menu_rounded,
                          iconColor: _warmAmber,
                          title: 'Browse Complete Food Catalog',
                          subtitle:
                              'Dishes added by Nivetha Catering & feast menus',
                          onTap: () => Navigator.pushNamed(context, '/menu'),
                        ),
                        const Divider(height: 1, color: _warmSandBorder),
                        _buildProfileTile(
                          icon: Icons.add_business_rounded,
                          iconColor: _forestEmerald,
                          title: 'Plan a New Event Booking',
                          subtitle: 'Weddings, Receptions, Housewarmings',
                          onTap: () =>
                              Navigator.pushNamed(context, '/create-booking'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // About & Support Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _warmSandBorder, width: 1.1),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          icon: Icons.message_rounded,
                          iconColor: _warmAmber,
                          title: 'Customer Support (Message Only)',
                          subtitle: '$_supportPhoneDisplay (Send SMS)',
                          onTap: _messageSupport,
                        ),
                        const Divider(height: 1, color: _warmSandBorder),
                        _buildProfileTile(
                          icon: Icons.info_outline_rounded,
                          iconColor: _forestEmerald,
                          title: 'About Nivetha Catering',
                          subtitle:
                              'Authentic South Indian feasts & gracious hospitality',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Nivetha Catering',
                              applicationVersion: '2.0.0',
                              applicationIcon: const Icon(
                                Icons.restaurant_rounded,
                                size: 40,
                                color: _forestEmerald,
                              ),
                              children: const [
                                Text(
                                  'Nivetha Catering delivers traditional South Indian event feasts, live counters, and dedicated hospitality for your celebrations.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: _inkDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: _inkMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: _inkMuted),
    );
  }
}