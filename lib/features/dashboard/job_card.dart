import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobCard extends StatelessWidget {
  final String company;
  final String role;
  final String status;
  final DateTime appliedDate;
  final String? source;
  final String? hiringManagerName;
  final String? hiringManagerUrl;
  final String? country;
  final String? workMode;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;

  const JobCard({
    super.key,
    required this.company,
    required this.role,
    required this.status,
    required this.appliedDate,
    this.source,
    this.hiringManagerName,
    this.hiringManagerUrl,
    this.country,
    this.workMode,
    this.onTap,
    this.onStatusChanged,
  });

  String _getFlag(String? countryCode) {
    if (countryCode == null) return '';
    const flags = {
      'US': '🇺🇸', 'USA': '🇺🇸', 'AE': '🇦🇪', 'UAE': '🇦🇪', 
      'UK': '🇬🇧', 'GB': '🇬🇧', 'CA': '🇨🇦', 'IN': '🇮🇳',
      'DE': '🇩🇪', 'FR': '🇫🇷', 'SA': '🇸🇦', 'KSA': '🇸🇦'
    };
    return flags[countryCode.toUpperCase()] ?? countryCode.toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied': return const Color(0xFF3B82F6);
      case 'cv_viewed': return const Color(0xFF8B5CF6);
      case 'cv_downloaded': return const Color(0xFF7C3AED);
      case 'interviewing': return const Color(0xFFF59E0B);
      case 'offer': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      case 'ghosted': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _daysSince(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1d';
    if (days < 7) return '${days}d';
    if (days < 30) return '${(days / 7).floor()}w';
    return '${(days / 30).floor()}mo';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Company + Time
              Row(
                children: [
                  // Company Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.2),
                          statusColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        company.isNotEmpty ? company[0].toUpperCase() : '?',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Company & Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          company,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Time Badge
                  Text(
                    _daysSince(appliedDate),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom Row: Badges + Status
              Row(
                children: [
                  // Meta badges (compact inline)
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (country != null)
                          _buildMiniChip(_getFlag(country), isDark),
                        if (workMode != null)
                          _buildMiniChip(
                            workMode!.substring(0, 1).toUpperCase() + workMode!.substring(1),
                            isDark,
                            color: workMode?.toLowerCase() == 'remote' 
                                ? Colors.green 
                                : workMode?.toLowerCase() == 'hybrid' 
                                    ? Colors.blue 
                                    : Colors.orange,
                          ),
                        if (source != null)
                          _buildMiniChip(source!, isDark),
                      ],
                    ),
                  ),
                  
                  // Status Dropdown
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    initialValue: status,
                    onSelected: onStatusChanged,
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      'applied', 'cv_viewed', 'interviewing', 'offer', 'rejected', 'ghosted'
                    ].map((s) => PopupMenuItem(
                      value: s,
                      height: 36,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(s),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_formatStatus(s), style: GoogleFonts.inter(fontSize: 12)),
                        ],
                      ),
                    )).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatStatus(status),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: statusColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text, bool isDark, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: isDark ? 0.2 : 0.1) ?? 
               (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(6),
        border: color != null 
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color ?? (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }
}
