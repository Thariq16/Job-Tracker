/// Admin Dashboard Screen
///
/// Admin-only screen showing platform statistics.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'admin_provider.dart';


class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userStatsProvider);
              ref.invalidate(jobStatsProvider);
              ref.invalidate(featureRequestsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatsProvider);
          ref.invalidate(jobStatsProvider);
          ref.invalidate(featureRequestsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E3A5F), const Color(0xFF0D2137)]
                      : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Platform statistics overview',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // User Stats Card
            _buildUserStatsCard(context, ref, isDark),

            const SizedBox(height: 16),

            // Job Stats Card
            _buildJobStatsCard(context, ref, isDark),

            const SizedBox(height: 16),

            // Company Stats Card
            _buildCompanyStatsCard(context, ref, isDark),

            const SizedBox(height: 16),

            // Feature Requests Card
            _buildFeatureRequestsCard(context, ref, isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsCard(BuildContext context, WidgetRef ref, bool isDark) {
    final userStats = ref.watch(userStatsProvider);

    return _StatCard(
      title: 'Users',
      icon: Icons.people,
      iconColor: Colors.blue,
      isDark: isDark,
      child: userStats.when(
        data: (stats) => Column(
          children: [
            _StatRow(label: 'Total Users', value: _formatNumber(stats.totalUsers), isDark: isDark),
            _StatRow(label: 'Active (7 days)', value: _formatNumber(stats.activeUsers7d), isDark: isDark),
            _StatRow(label: 'Inactive (7 days)', value: _formatNumber(stats.inactiveUsers7d), isDark: isDark),
            _StatRow(label: 'Signups (30 days)', value: _formatNumber(stats.newUsers30d), isDark: isDark),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red[400])),
      ),
    );
  }

  Widget _buildJobStatsCard(BuildContext context, WidgetRef ref, bool isDark) {
    final jobStats = ref.watch(jobStatsProvider);

    return _StatCard(
      title: 'Jobs',
      icon: Icons.work,
      iconColor: Colors.green,
      isDark: isDark,
      child: jobStats.when(
        data: (stats) => Column(
          children: [
            _StatRow(label: 'Total Jobs', value: _formatNumber(stats.totalJobs), isDark: isDark),
            _StatRow(label: 'Unique Companies', value: _formatNumber(stats.uniqueCompanies), isDark: isDark),
            _StatRow(label: 'Avg per User', value: stats.avgJobsPerUser.toStringAsFixed(1), isDark: isDark),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red[400])),
      ),
    );
  }

  Widget _buildCompanyStatsCard(BuildContext context, WidgetRef ref, bool isDark) {
    final jobStats = ref.watch(jobStatsProvider);

    return _StatCard(
      title: 'Top Companies',
      icon: Icons.business,
      iconColor: Colors.purple,
      isDark: isDark,
      child: jobStats.when(
        data: (stats) => stats.topCompanies.isEmpty
            ? Text('No job data yet', style: GoogleFonts.inter(color: Colors.grey))
            : Column(
                children: stats.topCompanies.entries.map((e) => 
                  _StatRow(label: e.key, value: '${e.value} jobs', isDark: isDark)
                ).toList(),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red[400])),
      ),
    );
  }

  Widget _buildFeatureRequestsCard(BuildContext context, WidgetRef ref, bool isDark) {
    final requests = ref.watch(featureRequestsProvider);
    final count = ref.watch(featureRequestCountProvider);

    return _StatCard(
      title: 'Feature Requests',
      icon: Icons.lightbulb,
      iconColor: Colors.amber,
      isDark: isDark,
      trailing: count.whenOrNull(
        data: (c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$c total',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber[700]),
          ),
        ),
      ),
      child: requests.when(
        data: (list) => list.isEmpty
            ? Text('No requests yet', style: GoogleFonts.inter(color: Colors.grey))
            : Column(
                children: list.map((req) => _FeatureRequestRow(
                  name: req['featureName'] ?? 'Untitled',
                  email: req['userEmail'] ?? 'Unknown',
                  isDark: isDark,
                )).toList(),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red[400])),
      ),
    );
  }

  String _formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Widget child;
  final Widget? trailing;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRequestRow extends StatelessWidget {
  final String name;
  final String email;
  final bool isDark;

  const _FeatureRequestRow({required this.name, required this.email, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
