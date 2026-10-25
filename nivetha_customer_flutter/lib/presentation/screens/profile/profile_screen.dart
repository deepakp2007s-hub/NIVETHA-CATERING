
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

import '../../../core/services/api_service.dart';

import '../auth/login_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _darkBrown = Color(0xFF402719);
  static const Color _brown = Color(0xFF765039);
  static const Color _gold = Color(0xFFD5A64A);
  static const Color _lightGold = Color(0xFFF5E5C2);

  final ApiService _api = ApiService.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _customerName = '';
  String _phoneNumber = '';
  String _email = '';

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await _api.get('customer-auth/profile');
      final customer = response['customer'];

      if (customer is! Map) {
        throw Exception('Invalid profile response from server.');
      }

      if (!mounted) return;

      setState(() {
        _customerName = _readString(customer['name']);
        _phoneNumber = _readString(customer['phone']);
        _email = _readString(customer['email']);

        _nameController.text = _customerName;
        _phoneController.text = _phoneNumber;
        _emailController.text = _email;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showMessage(
        'Could not load profile. Please check your connection and login.',
      );
    }
  }

  String _readString(dynamic value) {
    return value == null ? '' : value.toString().trim();
  }

  void _editProfile() {
    _nameController.text = _customerName;
    _phoneController.text = _phoneNumber;
    _emailController.text = _email;

    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }

    if (name.length > 100) {
      _showMessage('Name cannot exceed 100 characters.');
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await _api.put(
        'customer-auth/profile',
        body: {
          'name': name,
          'email': email,
        },
      );

      final customer = response['customer'];

      if (customer is Map) {
        _customerName = _readString(customer['name']).isNotEmpty
            ? _readString(customer['name'])
            : name;

        _email = _readString(customer['email']);
        _phoneNumber = _readString(customer['phone']).isNotEmpty
            ? _readString(customer['phone'])
            : _phoneNumber;
      } else {
        _customerName = name;
        _email = email;
      }

      _nameController.text = _customerName;
      _emailController.text = _email;
      _phoneController.text = _phoneNumber;

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      _showMessage('Profile updated successfully.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      _showMessage('Unable to update profile. Please try again.');
    }
  }

  void _cancelEditing() {
    _nameController.text = _customerName;
    _emailController.text = _email;
    _phoneController.text = _phoneNumber;

    setState(() => _isEditing = false);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: _darkBrown,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(color: _brown, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _brown),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await AuthService.instance.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const AuthScreens(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);
      _showMessage('Logout failed. Please try again.');
    }
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Choose Language',
          style: TextStyle(
            color: _darkBrown,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Tamil and English language settings can be managed from the app language preferences.',
          style: TextStyle(color: _brown, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: _darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Nivetha Catering Service',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _darkBrown,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.restaurant_rounded,
          color: _gold,
          size: 32,
        ),
      ),
      children: const [
        Text(
          'Nivetha Catering Service helps you plan catering for weddings, birthdays, family functions, and special events.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _darkBrown,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              tooltip: 'Refresh profile',
              onPressed: _loadProfile,
              icon: const Icon(
                Icons.refresh_rounded,
                color: _darkBrown,
              ),
            ),
          if (!_isEditing && !_isLoading)
            IconButton(
              tooltip: 'Edit profile',
              onPressed: _editProfile,
              icon: const Icon(
                Icons.edit_outlined,
                color: _darkBrown,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _gold),
              )
            : RefreshIndicator(
                color: _darkBrown,
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 25),
                      if (_isEditing) ...[
                        _buildEditForm(),
                        const SizedBox(height: 25),
                      ] else ...[
                        _buildPersonalDetails(),
                        const SizedBox(height: 28),
                      ],
                      _sectionTitle('My Account'),
                      const SizedBox(height: 13),
                      _profileOption(
                        icon: Icons.receipt_long_rounded,
                        title: 'My Bookings',
                        subtitle: 'View your catering bookings',
                        onTap: () => _openScreen(
                          const MyBookingsScreen(),
                        ),
                      ),
                      _profileOption(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifications',
                        subtitle: 'Stay updated with important information',
                        onTap: () => _openScreen(
                          const NotificationsScreen(),
                        ),
                      ),
                      _profileOption(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'Tamil and English preferences',
                        onTap: _showLanguageDialog,
                      ),
                      const SizedBox(height: 25),
                      _sectionTitle('Support & Information'),
                      const SizedBox(height: 13),
                      _profileOption(
                        icon: Icons.info_outline_rounded,
                        title: 'About Nivetha',
                        subtitle: 'Learn more about our catering service',
                        onTap: _showAboutDialog,
                      ),
                      _profileOption(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get assistance with your booking',
                        onTap: () => _showMessage(
                          'Please contact the catering service for assistance.',
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildLogoutButton(),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'NIVETHA CATERING SERVICE',
                              style: TextStyle(
                                color: _brown,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Made with love for your special occasions',
                              style: TextStyle(
                                color: _brown.withValues(alpha: 0.65),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName =
        _customerName.isEmpty ? 'Welcome!' : _customerName;
    final displayPhone =
        _phoneNumber.isEmpty ? 'Mobile number not available' : _phoneNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF503322), Color(0xFF2E1B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _gold.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.15),
              border: Border.all(color: _gold, width: 2.5),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: _gold,
              size: 51,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            displayPhone,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _gold.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: _gold,
                  size: 16,
                ),
                SizedBox(width: 7),
                Text(
                  'Nivetha Customer',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Personal Information'),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _lightGold),
          ),
          child: Column(
            children: [
              _detailRow(
                Icons.person_outline_rounded,
                'Full Name',
                _customerName.isEmpty ? 'Not added' : _customerName,
              ),
              _detailDivider(),
              _detailRow(
                Icons.phone_outlined,
                'Mobile Number',
                _phoneNumber.isEmpty ? 'Not added' : _phoneNumber,
              ),
              _detailDivider(),
              _detailRow(
                Icons.email_outlined,
                'Email Address',
                _email.isEmpty ? 'Not added' : _email,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit Information'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _darkBrown,
                    side: const BorderSide(color: _gold),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _lightGold.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _darkBrown, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _darkBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        height: 1,
        color: _lightGold.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Personal Information',
            style: TextStyle(
              color: _darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _inputField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your name',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 15),
          _inputField(
            controller: _phoneController,
            label: 'Mobile Number',
            hint: 'Mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            readOnly: true,
            helperText: 'Mobile number cannot be changed here.',
          ),
          const SizedBox(height: 15),
          _inputField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brown,
                    side: const BorderSide(color: _lightGold),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    bool readOnly = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _darkBrown,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: Icon(icon, color: _brown, size: 20),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF1E8DA) : _cream,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _lightGold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _lightGold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: _gold,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _darkBrown,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _lightGold),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: _lightGold.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _darkBrown, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _darkBrown,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.5,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: _brown,
          size: 23,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _showLogoutDialog,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded, size: 19),
        label: Text(
          _isLoggingOut ? 'Logging out...' : 'Logout',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFAD3939),
          side: const BorderSide(color: Color(0xFFE8B8B8)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
