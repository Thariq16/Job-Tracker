/// Target Company Prompt Dialog
///
/// Shows after saving a job to prompt user to add the company to Target Companies.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../target_companies/target_company_model.dart';
import '../target_companies/target_companies_provider.dart';

/// Shows a dialog prompting the user to add a company to their Target Companies list
/// Returns true if company was added, false if skipped
Future<bool> showAddToTargetCompaniesPrompt({
  required BuildContext context,
  required WidgetRef ref,
  required String companyName,
  String? sourceJobId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AddToTargetCompaniesDialog(
      companyName: companyName,
      sourceJobId: sourceJobId,
    ),
  );

  return result ?? false;
}

class _AddToTargetCompaniesDialog extends ConsumerStatefulWidget {
  final String companyName;
  final String? sourceJobId;

  const _AddToTargetCompaniesDialog({
    required this.companyName,
    this.sourceJobId,
  });

  @override
  ConsumerState<_AddToTargetCompaniesDialog> createState() => _AddToTargetCompaniesDialogState();
}

class _AddToTargetCompaniesDialogState extends ConsumerState<_AddToTargetCompaniesDialog> {
  bool _showForm = false;
  bool _isSubmitting = false;

  final _websiteController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _notesController = TextEditingController();
  Industry _selectedIndustry = Industry.technology;

  @override
  void dispose() {
    _websiteController.dispose();
    _linkedInController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(0),
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                        : [const Color(0xFF0077B5), const Color(0xFF00A0DC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add to Target Companies?',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: _showForm ? _buildForm(isDark) : _buildPrompt(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrompt(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            children: [
              TextSpan(
                text: '"${widget.companyName}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' looks interesting. Want to add it to your target list?'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This helps you:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              ...[
                'Track companies you\'re targeting',
                'Find connection targets on LinkedIn',
                'Research before interviews',
              ].map((text) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 14, color: Colors.green[400]),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _showForm = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Add Company'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Research tip
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Research tip: Visit the company website and LinkedIn!',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.amber[200] : Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Company name (read-only)
        _buildLabel('Company', isDark),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.companyName,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Industry dropdown
        _buildLabel('Industry', isDark),
        const SizedBox(height: 4),
        DropdownButtonFormField<Industry>(
          value: _selectedIndustry,
          decoration: _inputDecoration(isDark),
          dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          items: Industry.values.map((industry) {
            return DropdownMenuItem(
              value: industry,
              child: Text(industry.displayName, style: GoogleFonts.inter(fontSize: 13)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedIndustry = value);
          },
        ),
        const SizedBox(height: 12),

        // Website (optional)
        _buildLabel('Website (optional)', isDark),
        const SizedBox(height: 4),
        TextFormField(
          controller: _websiteController,
          decoration: _inputDecoration(isDark, hint: 'e.g., company.com'),
          style: GoogleFonts.inter(fontSize: 13),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),

        // LinkedIn (optional)
        _buildLabel('LinkedIn (optional)', isDark),
        const SizedBox(height: 4),
        TextFormField(
          controller: _linkedInController,
          decoration: _inputDecoration(isDark, hint: 'e.g., linkedin.com/company/...'),
          style: GoogleFonts.inter(fontSize: 13),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 20),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0077B5), width: 1.5),
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final id = await ref.read(targetCompaniesControllerProvider.notifier).addCompany(
        companyName: widget.companyName,
        websiteUrl: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
        linkedInUrl: _linkedInController.text.trim().isNotEmpty ? _linkedInController.text.trim() : null,
        industry: _selectedIndustry,
        sourceJobId: widget.sourceJobId,
      );

      if (mounted) {
        if (id != null) {
          Navigator.pop(context, true);
        } else {
          // Check for duplicate error
          final state = ref.read(targetCompaniesControllerProvider);
          if (state.hasError && state.error.toString().contains('already exists')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This company is already in your list'), backgroundColor: Colors.orange),
            );
            Navigator.pop(context, false);
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
