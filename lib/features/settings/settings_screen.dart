import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_tracker/core/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

          _buildSection('Notifications', [
            _buildSettingTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            _buildSettingTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Application status updates',
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
          ], isDark),

          const SizedBox(height: 16),

          _buildSection('Data', [
            _buildSettingTile(
              context,
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your job applications',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.delete_outline,
              title: 'Clear All Data',
              subtitle: 'Remove all applications',
              isDestructive: true,
              onTap: () {},
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
