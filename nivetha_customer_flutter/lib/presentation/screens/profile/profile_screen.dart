
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final String? customerName;
  final String? mobileNumber;
  final String? email;

  const ProfileScreen({
    super.key,
    this.customerName,
    this.mobileNumber,
    this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _language = 'en';

  bool get _isTamil => _language == 'ta';

  String _text(String english, String tamil) {
    return _isTamil ? tamil : english;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.customerName?.trim().isNotEmpty == true
        ? widget.customerName!.trim()
        : _text('Guest Customer', 'விருந்தினர்');

    final mobile = widget.mobileNumber?.trim().isNotEmpty == true
        ? widget.mobileNumber!.trim()
        : _text('Not provided', 'வழங்கப்படவில்லை');

    final email = widget.email?.trim().isNotEmpty == true
        ? widget.email!.trim()
        : _text('Not provided', 'வழங்கப்படவில்லை');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_text('My Profile', 'என் சுயவிவரம்')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryGreenDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildProfileHeader(name),
            const SizedBox(height: 24),
            _sectionTitle(_text('Personal Details', 'தனிப்பட்ட விவரங்கள்')),
            const SizedBox(height: 12),
            _buildDetailTile(
              icon: Icons.person_outline_rounded,
              title: _text('Full Name', 'முழுப் பெயர்'),
              value: name,
            ),
            _buildDetailTile(
              icon: Icons.phone_outlined,
              title: _text('Mobile Number', 'மொபைல் எண்'),
              value: mobile,
            ),
            _buildDetailTile(
              icon: Icons.email_outlined,
              title: _text('Email Address', 'மின்னஞ்சல் முகவரி'),
              value: email,
            ),
            const SizedBox(height: 24),
            _sectionTitle(_text('Preferences', 'விருப்பங்கள்')),
            const SizedBox(height: 12),
            _buildLanguageTile(),
            const SizedBox(height: 24),
            _sectionTitle(_text('Account', 'கணக்கு')),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.notifications_outlined,
              title: _text('Notifications', 'அறிவிப்புகள்'),
              subtitle: _text(
                'Booking updates and reminders',
                'முன்பதிவு தகவல்கள் மற்றும் நினைவூட்டல்கள்',
              ),
              onTap: () => _showMessage(
                _text(
                  'Open the Alerts tab to view notifications.',
                  'அறிவிப்புகளைப் பார்க்க Alerts பகுதியைத் திறக்கவும்.',
                ),
              ),
            ),
            _buildActionTile(
              icon: Icons.help_outline_rounded,
              title: _text('Help & Support', 'உதவி மற்றும் ஆதரவு'),
              subtitle: _text(
                'Get help with your catering booking',
                'உங்கள் முன்பதிவுக்கு உதவி பெறுங்கள்',
              ),
              onTap: _showSupportDialog,
            ),
            _buildActionTile(
              icon: Icons.info_outline_rounded,
              title: _text('About Nivetha', 'நிவேதா பற்றி'),
              subtitle: _text(
                'Nivetha Catering Service',
                'நிவேதா கேட்டரிங் சர்வீஸ்',
              ),
              onTap: _showAboutDialog,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
              label: Text(_text('Sign Out', 'வெளியேறு')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _text(
                'Nivetha Catering Service',
                'நிவேதா கேட்டரிங் சர்வீஸ்',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGreenDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldAccent,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 45,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _text(
              'Welcome to Nivetha Catering',
              'நிவேதா கேட்டரிங்கிற்கு வரவேற்கிறோம்',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
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

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _iconContainer(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconContainer(Icons.language_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _text('App Language', 'செயலி மொழி'),
                  style: const TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _languageOption(
            code: 'en',
            title: 'English',
            subtitle: 'English language',
          ),
          const SizedBox(height: 8),
          _languageOption(
            code: 'ta',
            title: 'தமிழ் (Tamil)',
            subtitle: 'தமிழ் மொழி',
          ),
          const SizedBox(height: 10),
          Text(
            _text(
              'Language selection currently applies to this screen only.',
              'மொழித் தேர்வு தற்போது இந்தத் திரைக்கு மட்டும் பொருந்தும்.',
            ),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageOption({
    required String code,
    required String title,
    required String subtitle,
  }) {
    final selected = _language == code;

    return InkWell(
      onTap: () {
        setState(() {
          _language = code;
        });
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: _iconContainer(icon),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGreenDark,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _iconContainer(IconData icon) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 22,
      ),
    );
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

  void _showSupportDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Help & Support', 'உதவி மற்றும் ஆதரவு')),
        content: Text(
          _text(
            'Please contact Nivetha Catering Service for assistance.',
            'உதவிக்கு நிவேதா கேட்டரிங் சர்வீஸைத் தொடர்பு கொள்ளுங்கள்.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_text('Close', 'மூடு')),
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
      applicationIcon: const Icon(
        Icons.restaurant_rounded,
        color: AppColors.primary,
        size: 36,
      ),
      children: const <Widget>[
        Text('Catering for your special occasions.'),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Sign Out?', 'வெளியேற வேண்டுமா?')),
        content: Text(
          _text(
            'Are you sure you want to sign out?',
            'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text('Cancel', 'ரத்து செய்')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text('Sign Out', 'வெளியேறு')),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    _showMessage(
      _text(
        'Authentication logout is not connected yet.',
        'Authentication logout இன்னும் இணைக்கப்படவில்லை.',
      ),
    );
  }
}
