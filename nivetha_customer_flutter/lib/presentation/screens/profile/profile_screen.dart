
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../auth/login_screen.dart';
import '../bookings/my_bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  String _name = 'Nivetha Customer';
  String _email = '';
  String _phone = '';
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final name = await AuthStorageService.getCustomerName();
      final email = await AuthStorageService.getCustomerEmail();
      final phone = await AuthStorageService.getCustomerPhone();

      if (!mounted) return;

      setState(() {
        if (name != null && name.trim().isNotEmpty) {
          _name = name.trim();
        }

        _email = email ?? '';
        _phone = phone ?? '';
        _isLoading = false;
      });

      _controller.forward(from: 0);
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _controller.forward(from: 0);
    }
  }

  String get _initials {
    final parts = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'N';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          title: const Text(
            'Personal Details',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 13),
                _dialogField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 13),
                _dialogField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                Text(
                  'These changes are displayed in this session. Server-side profile saving requires a profile update API.',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: navy),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'name': name,
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      _name = result['name'] ?? _name;
      _email = result['email'] ?? _email;
      _phone = result['phone'] ?? _phone;
    });

    _showMessage('Profile updated for this session.');
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: navy,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: gold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFC54646),
            size: 36,
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: navy),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC54646),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await AuthService.instance.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);
      _showMessage('Unable to log out. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
        ),
      );
  }

  void _openBookings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyBookingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          onRefresh: _loadProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 23, 20, 30),
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(color: gold),
                  ),
                )
              else
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildProfileCard(),
                  ),
                ),

              const SizedBox(height: 26),

              const Text(
                'Account Settings',
                style: TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              _settingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Details',
                subtitle: 'Name, email and phone number',
                onTap: _editProfile,
              ),

              _settingsTile(
                icon: Icons.receipt_long_rounded,
                title: 'My Bookings',
                subtitle: 'View your catering reservations',
                onTap: _openBookings,
              ),

              _settingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'Tamil and English',
                onTap: _showLanguageInfo,
              ),

              _settingsTile(
                icon: Icons.support_agent_rounded,
                title: 'Help & Support',
                subtitle: 'Contact Nivetha Catering Service',
                onTap: _showSupport,
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _confirmLogout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    _isLoggingOut ? 'Logging out...' : 'Logout',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC54646),
                    side: const BorderSide(
                      color: Color(0xFFE5B8B8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'NIVETHA CATERING SERVICE',
                  style: TextStyle(
                    color: Color(0xFF987022),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Made with care for your special moments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'என் கணக்கு விவரங்கள்',
                style: TextStyle(
                  color: Color(0xFF987022),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.account_circle_rounded,
          color: gold,
          size: 34,
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF294D70),
            navy,
            Color(0xFF091629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.20),
            blurRadius: 23,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFE6A2),
                      gold,
                      Color(0xFFB77A20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.27),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: const Color(0xFF48C58B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: navy,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            _name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _email.isNotEmpty
                ? _email
                : _phone.isNotEmpty
                    ? _phone
                    : 'Welcome to Nivetha Catering',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 19),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: gold.withValues(alpha: 0.36),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: gold,
                  size: 17,
                ),
                SizedBox(width: 8),
                Text(
                  'Customer Account',
                  style: TextStyle(
                    color: Color(0xFFFFE6A2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 47,
            child: ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_rounded, size: 17),
              label: const Text(
                'Edit Personal Details',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 7,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: navy,
            size: 23,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              fontSize: 10,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: gold,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageInfo() {
    _showMessage(
      'Use the language option in the app navigation to switch Tamil and English.',
    );
  }

  void _showSupport() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.support_agent_rounded,
            color: gold,
            size: 38,
          ),
          title: const Text(
            'Help & Support',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'For booking changes, event details or catering enquiries, please contact Nivetha Catering Service directly.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: navy),
              ),
            ),
          ],
        );
      },
    );
  }
}
