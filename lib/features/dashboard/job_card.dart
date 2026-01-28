import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
    // Simple mapping for common codes, or use a package.
    // MVP: Just text or simple emoji map
    const flags = {
      'US': '🇺🇸', 'USA': '🇺🇸', 'AE': '🇦🇪', 'UAE': '🇦🇪', 
      'UK': '🇬🇧', 'GB': '🇬🇧', 'CA': '🇨🇦', 'IN': '🇮🇳',
      'DE': '🇩🇪', 'FR': '🇫🇷', 'SA': '🇸🇦', 'KSA': '🇸🇦'
    };
    return flags[countryCode.toUpperCase()] ?? countryCode.toUpperCase();
  }

  Color _getWorkModeColor(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'remote': return Colors.green;
      case 'hybrid': return Colors.blue;
      case 'onsite': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'cv_viewed':
        return Colors.purple;
      case 'cv_downloaded':
        return Colors.deepPurple;
      case 'interviewing':
        return Colors.orange;
      case 'offer':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'ghosted':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _daysSince(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Placeholder or Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            role,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Date Tracker
                        Text(
                           _daysSince(appliedDate),
                           style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, 
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Source Badge
                        if (source != null) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              source!,
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[800]), 
                            ),
                          ),
                        
                        // Country Flag
                        if (country != null)
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!)
                            ),
                            child: Text(
                              _getFlag(country),
                              style: const TextStyle(fontSize: 12), 
                            ),
                          ),

                        // Work Mode
                        if (workMode != null)
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getWorkModeColor(workMode).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _getWorkModeColor(workMode).withOpacity(0.3))
                            ),
                            child: Text(
                              workMode![0].toUpperCase() + workMode!.substring(1),
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _getWorkModeColor(workMode)), 
                            ),
                          ),
                      ],
                    ),
                    
                    if (hiringManagerName != null) ...[
                       const SizedBox(height: 8),
                       Row(
                         children: [
                           Icon(Icons.person_pin, size: 14, color: Colors.indigo[300]),
                           const SizedBox(width: 4),
                           Text("Hiring: $hiringManagerName", style: GoogleFonts.inter(fontSize: 11, color: Colors.indigo[300])),
                           if (hiringManagerUrl != null) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => launchUrl(Uri.parse(hiringManagerUrl!)),
                                child: Icon(Icons.link, size: 14, color: Colors.indigo[300]),
                              )
                           ]
                         ],
                       )
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge with Popup
              PopupMenuButton<String>(
                initialValue: status,
                onSelected: onStatusChanged,
                itemBuilder: (context) => [
                  'applied', 'cv_viewed', 'cv_downloaded', 'interviewing', 'offer', 'rejected', 'ghosted'
                ].map((s) => PopupMenuItem(
                  value: s,
                  child: Text(_formatStatus(s), style: const TextStyle(fontSize: 12)),
                )).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatStatus(status),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 14, color: _getStatusColor(status)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
