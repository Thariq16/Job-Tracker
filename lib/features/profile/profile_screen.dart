import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_repository.dart';
import '../auth/auth_repository.dart';

// Country list with codes
const List<Map<String, String>> countries = [
  {'name': 'United Arab Emirates', 'code': 'AE', 'phone': '+971'},
  {'name': 'Saudi Arabia', 'code': 'SA', 'phone': '+966'},
  {'name': 'United States', 'code': 'US', 'phone': '+1'},
  {'name': 'United Kingdom', 'code': 'GB', 'phone': '+44'},
  {'name': 'Canada', 'code': 'CA', 'phone': '+1'},
  {'name': 'Germany', 'code': 'DE', 'phone': '+49'},
  {'name': 'France', 'code': 'FR', 'phone': '+33'},
  {'name': 'India', 'code': 'IN', 'phone': '+91'},
  {'name': 'Australia', 'code': 'AU', 'phone': '+61'},
  {'name': 'Singapore', 'code': 'SG', 'phone': '+65'},
  {'name': 'Qatar', 'code': 'QA', 'phone': '+974'},
  {'name': 'Kuwait', 'code': 'KW', 'phone': '+965'},
  {'name': 'Bahrain', 'code': 'BH', 'phone': '+973'},
  {'name': 'Oman', 'code': 'OM', 'phone': '+968'},
  {'name': 'Egypt', 'code': 'EG', 'phone': '+20'},
  {'name': 'Jordan', 'code': 'JO', 'phone': '+962'},
  {'name': 'Lebanon', 'code': 'LB', 'phone': '+961'},
  {'name': 'Pakistan', 'code': 'PK', 'phone': '+92'},
  {'name': 'Netherlands', 'code': 'NL', 'phone': '+31'},
  {'name': 'Spain', 'code': 'ES', 'phone': '+34'},
  {'name': 'Italy', 'code': 'IT', 'phone': '+39'},
  {'name': 'Switzerland', 'code': 'CH', 'phone': '+41'},
  {'name': 'Ireland', 'code': 'IE', 'phone': '+353'},
  {'name': 'New Zealand', 'code': 'NZ', 'phone': '+64'},
  {'name': 'Japan', 'code': 'JP', 'phone': '+81'},
  {'name': 'South Korea', 'code': 'KR', 'phone': '+82'},
  {'name': 'China', 'code': 'CN', 'phone': '+86'},
  {'name': 'Malaysia', 'code': 'MY', 'phone': '+60'},
  {'name': 'Indonesia', 'code': 'ID', 'phone': '+62'},
  {'name': 'Thailand', 'code': 'TH', 'phone': '+66'},
  {'name': 'Philippines', 'code': 'PH', 'phone': '+63'},
  {'name': 'South Africa', 'code': 'ZA', 'phone': '+27'},
  {'name': 'Nigeria', 'code': 'NG', 'phone': '+234'},
  {'name': 'Kenya', 'code': 'KE', 'phone': '+254'},
  {'name': 'Brazil', 'code': 'BR', 'phone': '+55'},
  {'name': 'Mexico', 'code': 'MX', 'phone': '+52'},
  {'name': 'Argentina', 'code': 'AR', 'phone': '+54'},
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  bool _isSaved = false;
  final _targetRoleController = TextEditingController();

  void _showSaveIndicator() {
    setState(() => _isSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSaved = false);
    });
  }

  Future<void> _uploadCV() async {
    setState(() => _isUploading = true);
    try {
      await ref.read(profileRepositoryProvider).uploadCV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploaded successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _targetRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaved)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  Text("Saved", style: TextStyle(color: Colors.green[700], fontSize: 12)),
                ],
              ),
            ).animate().fadeIn().fadeOut(delay: 1500.ms),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Photo
              if (profile.photoUrl != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade400, Colors.purple.shade400],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profile.photoUrl!),
                    ),
                  ),
                ).animate().scale(),
              
              const SizedBox(height: 32),
              
              // Section: Personal Info
              _buildSectionHeader('Personal Information', Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildCard([
                TextFormField(
                  initialValue: profile.fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  onChanged: (val) {
                    ref.read(profileRepositoryProvider).updateProfile(fullName: val);
                    _showSaveIndicator();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: profile.jobTitle,
                  decoration: const InputDecoration(
                    labelText: 'Current Job Title',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  onChanged: (val) {
                    ref.read(profileRepositoryProvider).updateProfile(jobTitle: val);
                    _showSaveIndicator();
                  },
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Section: Contact
              _buildSectionHeader('Contact', Icons.phone_outlined),
              const SizedBox(height: 16),
              
              _buildCard([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Dropdown
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        value: profile.phoneCode,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        isExpanded: true,
                        items: countries.map((c) => DropdownMenuItem(
                          value: c['phone'],
                          child: Text(c['phone']!, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (val) {
                          ref.read(profileRepositoryProvider).updateProfile(phoneCode: val);
                          _showSaveIndicator();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone Number
                    Expanded(
                      child: TextFormField(
                        initialValue: profile.phoneNumber,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        onChanged: (val) {
                          ref.read(profileRepositoryProvider).updateProfile(phoneNumber: val);
                          _showSaveIndicator();
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Section: Location
              _buildSectionHeader('Location', Icons.location_on_outlined),
              const SizedBox(height: 16),
              
              _buildCard([
                DropdownButtonFormField<String>(
                  value: profile.currentCountry,
                  decoration: const InputDecoration(
                    labelText: 'Current Country',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  isExpanded: true,
                  items: countries.map((c) => DropdownMenuItem(
                    value: c['name'],
                    child: Text(c['name']!),
                  )).toList(),
                  onChanged: (val) {
                    ref.read(profileRepositoryProvider).updateProfile(currentCountry: val);
                    _showSaveIndicator();
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Open to Relocation"),
                  subtitle: Text("Show interest in opportunities abroad", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  value: profile.willingToRelocate ?? false,
                  onChanged: (val) {
                    ref.read(profileRepositoryProvider).updateProfile(willingToRelocate: val);
                    _showSaveIndicator();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                if (profile.willingToRelocate == true) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: profile.targetCountry,
                    decoration: const InputDecoration(
                      labelText: 'Target Country',
                      prefixIcon: Icon(Icons.flight_takeoff),
                    ),
                    isExpanded: true,
                    items: countries.map((c) => DropdownMenuItem(
                      value: c['name'],
                      child: Text(c['name']!),
                    )).toList(),
                    onChanged: (val) {
                      ref.read(profileRepositoryProvider).updateProfile(targetCountry: val);
                      _showSaveIndicator();
                    },
                  ),
                ],
              ]),
              
              const SizedBox(height: 24),
              
              // Section: Target Roles
              _buildSectionHeader('Target Roles', Icons.flag_outlined),
              const SizedBox(height: 16),
              
              _buildCard([
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...(profile.targetRoles ?? []).map((role) => Chip(
                      label: Text(role),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        final updated = List<String>.from(profile.targetRoles ?? []);
                        updated.remove(role);
                        ref.read(profileRepositoryProvider).updateProfile(targetRoles: updated);
                        _showSaveIndicator();
                      },
                      backgroundColor: Colors.indigo.shade50,
                      labelStyle: TextStyle(color: Colors.indigo.shade700),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetRoleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Product Manager, UX Designer',
                          isDense: true,
                        ),
                        onSubmitted: (val) => _addTargetRole(profile.targetRoles),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _addTargetRole(profile.targetRoles),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Section: CV
              _buildSectionHeader('My CV', Icons.description_outlined),
              const SizedBox(height: 16),
              
              _buildCard([
                if (profile.cvUrl != null) 
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.cvName ?? 'Uploaded CV', style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text('Tap to view', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => launchUrl(Uri.parse(profile.cvUrl!)),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Text('No CV uploaded yet', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _uploadCV,
                    icon: _isUploading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isUploading 
                      ? 'Uploading...' 
                      : profile.cvUrl != null ? 'Replace CV' : 'Upload CV'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ]),
              
              const SizedBox(height: 40),
              
              // Sign Out
              Center(
                child: TextButton.icon(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _addTargetRole(List<String>? currentRoles) {
    final role = _targetRoleController.text.trim();
    if (role.isEmpty) return;
    
    final updated = List<String>.from(currentRoles ?? []);
    if (!updated.contains(role)) {
      updated.add(role);
      ref.read(profileRepositoryProvider).updateProfile(targetRoles: updated);
      _showSaveIndicator();
    }
    _targetRoleController.clear();
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
