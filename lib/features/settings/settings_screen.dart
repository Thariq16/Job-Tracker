import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_tracker/core/theme_provider.dart';
import 'package:job_tracker/core/admin_guard.dart';
import 'feature_request_dialog.dart';
import 'bug_report_dialog.dart';
import '../nps/nps_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final showAdmin = isCurrentUserAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Re-enable when subscription feature is ready
          // _buildSection('Subscription', [
          //   _buildSettingTile(
          //     context,
          //     icon: Icons.workspace_premium,
          //     title: 'Manage Subscription',
          //     subtitle: 'Free Plan • Upgrade for more features',
          //     onTap: () => context.go('/subscription'),
          //   ),
          // ], isDark),

          // const SizedBox(height: 16),

          _buildSection('Appearance', [
            _buildSettingTile(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => toggleTheme(ref),
              ),
            ),
          ], isDark),

          const SizedBox(height: 16),

          // TODO: Re-enable when notifications feature is ready
          // _buildSection('Notifications', [
          //   _buildSettingTile(
          //     context,
          //     icon: Icons.email_outlined,
          //     title: 'Email Notifications',
          //     subtitle: 'Receive updates via email',
          //     trailing: Switch(value: true, onChanged: (_) {}),
          //   ),
          //   _buildSettingTile(
          //     context,
          //     icon: Icons.notifications_outlined,
          //     title: 'Push Notifications',
          //     subtitle: 'Application status updates',
          //     trailing: Switch(value: true, onChanged: (_) {}),
          //   ),
          // ], isDark),

          // const SizedBox(height: 16),

          // TODO: Re-enable when data export feature is ready
          // _buildSection('Data', [
          //   _buildSettingTile(
          //     context,
          //     icon: Icons.download_outlined,
          //     title: 'Export Data',
          //     subtitle: 'Download your job applications',
          //     onTap: () {},
          //   ),
          //   _buildSettingTile(
          //     context,
          //     icon: Icons.delete_outline,
          //     title: 'Clear All Data',
          //     subtitle: 'Remove all applications',
          //     isDestructive: true,
          //     onTap: () {},
          //   ),
          // ], isDark),

          // const SizedBox(height: 16),


          _buildSection('Feedback', [
            _buildSettingTile(
              context,
              icon: Icons.star_outline,
              title: 'Rate Us',
              subtitle: 'Tell us how we\'re doing',
              onTap: () => showNpsDialog(context, ref, trigger: 'settings'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.person_add_outlined,
              title: 'Invite Friends',
              subtitle: 'Share the app and earn rewards',
              onTap: () => context.push('/referral'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Request New Feature',
              subtitle: 'Share your ideas with us',
              onTap: () => showFeatureRequestDialog(context),
            ),
            _buildSettingTile(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve the app',
              onTap: () => showBugReportDialog(context),
            ),
          ], isDark),

          const SizedBox(height: 16),

          _buildSection('About', [
            _buildSettingTile(
              context,
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _buildSettingTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
          ], isDark),

          // Admin section - only visible to admins
          if (showAdmin) ...[
            const SizedBox(height: 16),
            _buildSection('Admin', [
              _buildSettingTile(
                context,
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Platform statistics & management',
                onTap: () => context.go('/admin'),
              ),
            ], isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDestructive ? Colors.red : null;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : (isDark ? Colors.grey[400] : Colors.grey[700]),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
      onTap: onTap,
    );
  }
}
