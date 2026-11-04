import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  late Future<CustomerModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _profileService.getProfile();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<CustomerModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load profile details.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _loadProfile()),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _handleLogout,
                      child: const Text('Log In Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Full Name'),
                        subtitle: Text(profile.name),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email Address'),
                        subtitle: Text(profile.email),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Phone Number'),
                        subtitle: Text(profile.phone.isNotEmpty ? profile.phone : 'Not provided'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: Colors.red.shade50,
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout Account',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: _handleLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}