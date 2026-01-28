import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_repository.dart';
import '../auth/auth_repository.dart';

// Country list with codes
const List<Map<String, String>> countries = [
  {'name': 'United Arab Emirates', 'code': 'AE', 'phone': '+971'},
  {'name': 'Saudi Arabia', 'code': 'SA', 'phone': '+966'},
  {'name': 'United States', 'code': 'US', 'phone': '+1'},
  {'name': 'United Kingdom', 'code': 'GB', 'phone': '+44'},
  {'name': 'Canada', 'code': 'CA', 'phone': '+1 CA'},
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
  bool _isSaving = false;
  bool _hasChanges = false;
  final _targetRoleController = TextEditingController();

  // Form fields to track changes
  String? _fullName;
  String? _jobTitle;
  String? _phoneCode;
  String? _phoneNumber;
  String? _currentCountry;
  String? _targetCountry;
  bool? _willingToRelocate;
  List<String>? _targetRoles;
  bool _initialized = false;

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
        fullName: _fullName,
        jobTitle: _jobTitle,
        phoneCode: _phoneCode,
        phoneNumber: _phoneNumber,
        currentCountry: _currentCountry,
        targetCountry: _targetCountry,
        willingToRelocate: _willingToRelocate,
        targetRoles: _targetRoles,
      );
      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Profile saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadCV() async {
    setState(() => _isUploading = true);
    try {
      await ref.read(profileRepositoryProvider).uploadCV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('CV uploaded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          // Initialize local state from profile on first load
          if (!_initialized) {
            _fullName = profile.fullName;
            _jobTitle = profile.jobTitle;
            _phoneCode = profile.phoneCode;
            _phoneNumber = profile.phoneNumber;
            _currentCountry = profile.currentCountry;
            _targetCountry = profile.targetCountry;
            _willingToRelocate = profile.willingToRelocate;
            _targetRoles = profile.targetRoles != null ? List.from(profile.targetRoles!) : [];
            _initialized = true;
          }

          return Stack(
            children: [
              SingleChildScrollView(
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
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Section: Personal Info
                    _buildSectionHeader('Personal Information', Icons.person_outline),
                    const SizedBox(height: 16),
                    
                    _buildCard([
                      TextFormField(
                        initialValue: _fullName,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onChanged: (val) {
                          _fullName = val;
                          _markChanged();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _jobTitle,
                        decoration: const InputDecoration(
                          labelText: 'Current Job Title',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        onChanged: (val) {
                          _jobTitle = val;
                          _markChanged();
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
                            width: 130,
                            child: DropdownButtonFormField<String>(
                              value: countries.any((c) => c['code'] == _phoneCode) 
                                  ? _phoneCode 
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Code',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              isExpanded: true,
                              items: countries.map((c) => DropdownMenuItem(
                                value: c['code'],
                                child: Text('${c['phone']} (${c['code']})', style: const TextStyle(fontSize: 12)),
                              )).toList(),
                              onChanged: (val) {
                                _phoneCode = val;
                                _markChanged();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Phone Number
                          Expanded(
                            child: TextFormField(
                              initialValue: _phoneNumber,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                              ),
                              onChanged: (val) {
                                _phoneNumber = val;
                                _markChanged();
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
                        value: _currentCountry,
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
                          setState(() => _currentCountry = val);
                          _markChanged();
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Open to Relocation"),
                        subtitle: Text("Show interest in opportunities abroad", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        value: _willingToRelocate ?? false,
                        onChanged: (val) {
                          setState(() => _willingToRelocate = val);
                          _markChanged();
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_willingToRelocate == true) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _targetCountry,
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
                            setState(() => _targetCountry = val);
                            _markChanged();
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
                          ...(_targetRoles ?? []).map((role) => Chip(
                            label: Text(role),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _targetRoles?.remove(role);
                              });
                              _markChanged();
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
                              onSubmitted: (val) => _addTargetRole(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addTargetRole,
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
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.picture_as_pdf, color: Colors.green.shade700, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.cvName ?? 'Uploaded CV',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '✓ Uploaded successfully',
                                      style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => launchUrl(Uri.parse(profile.cvUrl!)),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('View'),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                              const SizedBox(height: 8),
                              Text('No CV uploaded yet', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text('Upload your CV to share with applications', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadCV,
                          icon: _isUploading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined),
                          label: Text(_isUploading 
                            ? 'Uploading...' 
                            : profile.cvUrl != null ? 'Replace CV' : 'Upload CV (PDF, DOC)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: profile.cvUrl != null ? Colors.grey.shade600 : Colors.indigo,
                            foregroundColor: Colors.white,
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
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
              
              // Floating Save Button
              if (_hasChanges)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: SafeArea(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveChanges,
                      icon: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving Changes...' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _addTargetRole() {
    final role = _targetRoleController.text.trim();
    if (role.isEmpty) return;
    
    _targetRoles ??= [];
    if (!_targetRoles!.contains(role)) {
      setState(() {
        _targetRoles!.add(role);
      });
      _markChanged();
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
