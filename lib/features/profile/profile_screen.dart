import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_repository.dart';
import '../auth/auth_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  bool _isSaved = false;

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
          const SnackBar(
            content: Text('CV uploaded successfully!'),
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
              if (profile.photoUrl != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profile.photoUrl!),
                  ),
                ).animate().scale(),
                
              const SizedBox(height: 24),
              TextFormField(
                initialValue: profile.fullName,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                onChanged: (val) {
                  ref.read(profileRepositoryProvider).updateProfile(jobTitle: val);
                  _showSaveIndicator();
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: profile.phoneNumber,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (val) {
                  ref.read(profileRepositoryProvider).updateProfile(phoneNumber: val);
                  _showSaveIndicator();
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: profile.currentCountry,
                decoration: const InputDecoration(
                  labelText: 'Current Country (e.g. UAE)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (val) {
                  ref.read(profileRepositoryProvider).updateProfile(currentCountry: val);
                  _showSaveIndicator();
                },
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                 title: const Text("Willing to Relocate?"),
                 value: profile.willingToRelocate ?? false,
                 onChanged: (val) {
                   ref.read(profileRepositoryProvider).updateProfile(willingToRelocate: val);
                   _showSaveIndicator();
                 },
                 contentPadding: EdgeInsets.zero,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              const SizedBox(height: 16),

              if (profile.willingToRelocate == true) ...[
                 TextFormField(
                   initialValue: profile.targetCountry,
                   decoration: const InputDecoration(
                     labelText: 'Target Country (e.g. USA, UK)',
                     border: OutlineInputBorder(),
                     prefixIcon: Icon(Icons.flight_takeoff),
                   ),
                   onChanged: (val) {
                     ref.read(profileRepositoryProvider).updateProfile(targetCountry: val);
                     _showSaveIndicator();
                   },
                 ),
                 const SizedBox(height: 16),
              ],
              
              TextFormField(
                initialValue: profile.targetRole,
                decoration: const InputDecoration(
                  labelText: 'Target Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                onChanged: (val) {
                  ref.read(profileRepositoryProvider).updateProfile(targetRole: val);
                  _showSaveIndicator();
                },
              ),
              const SizedBox(height: 32),
              
              // CV Section
              Text("My CV", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 12),
              
              if (profile.cvUrl != null) 
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.withOpacity(0.05),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.cvName ?? 'Uploaded CV',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => launchUrl(Uri.parse(profile.cvUrl!)),
                        tooltip: 'View CV',
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(0.05),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      Text('No CV uploaded yet', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _uploadCV,
                icon: _isUploading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file),
                label: Text(_isUploading 
                  ? 'Uploading...' 
                  : profile.cvUrl != null ? 'Replace CV' : 'Upload CV'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sign Out
              TextButton.icon(
                onPressed: () async {
                   await ref.read(authRepositoryProvider).signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Sign Out", style: TextStyle(color: Colors.red)),
              )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
