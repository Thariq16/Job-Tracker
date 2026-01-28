import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_repository.dart';
import '../auth/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                },
              ),
              const SizedBox(height: 16),
              
              // Job Title
              TextFormField(
                initialValue: profile.jobTitle,
                decoration: const InputDecoration(
                  labelText: 'Current Job Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(jobTitle: val),
              ),
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                initialValue: profile.phoneNumber,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(phoneNumber: val),
              ),
              const SizedBox(height: 16),

              // Location & Relocation
              TextFormField(
                initialValue: profile.currentCountry,
                decoration: const InputDecoration(
                  labelText: 'Current Country (e.g. UAE)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(currentCountry: val),
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                 title: const Text("Willing to Relocate?"),
                 value: profile.willingToRelocate ?? false,
                 onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(willingToRelocate: val),
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
                   onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(targetCountry: val),
                 ),
                 const SizedBox(height: 16),
              ],
              
              // Target Role
              TextFormField(
                initialValue: profile.targetRole,
                decoration: const InputDecoration(
                  labelText: 'Target Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                onChanged: (val) => ref.read(profileRepositoryProvider).updateProfile(targetRole: val),
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
                ),
              
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref.read(profileRepositoryProvider).uploadCV(),
                icon: const Icon(Icons.upload_file),
                label: Text(profile.cvUrl != null ? 'Replace CV' : 'Upload CV'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sign Out
              TextButton.icon(
                onPressed: () async {
                   // No pop needed if logic redirects, but let's keep robust
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
