/// Add Target Company Screen
///
/// Form for adding or editing a target company.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'target_company_model.dart';
import 'target_companies_provider.dart';

class AddTargetCompanyScreen extends ConsumerStatefulWidget {
  final TargetCompany? company; // Null for add mode, populated for edit mode
  final String? initialCompanyName; // Pre-fill from job
  final String? sourceJobId;

  const AddTargetCompanyScreen({
    super.key,
    this.company,
    this.initialCompanyName,
    this.sourceJobId,
  });

  bool get isEditMode => company != null;

  @override
  ConsumerState<AddTargetCompanyScreen> createState() => _AddTargetCompanyScreenState();
}

class _AddTargetCompanyScreenState extends ConsumerState<AddTargetCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedInController;
  late TextEditingController _customIndustryController;
  late TextEditingController _notesController;

  Industry _selectedIndustry = Industry.technology;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final company = widget.company;

    _nameController = TextEditingController(
      text: company?.companyName ?? widget.initialCompanyName ?? '',
    );
    _websiteController = TextEditingController(text: company?.websiteUrl ?? '');
    _linkedInController = TextEditingController(text: company?.linkedInUrl ?? '');
    _customIndustryController = TextEditingController(text: company?.customIndustry ?? '');
    _notesController = TextEditingController(text: company?.notes ?? '');

    if (company != null) {
      _selectedIndustry = company.industry;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _linkedInController.dispose();
    _customIndustryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customIndustriesAsync = ref.watch(customIndustriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Company' : 'Add Company',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Research Tip (only for add mode)
            if (!widget.isEditMode) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Visit the company website and LinkedIn page to gather this information. This research helps you prepare for interviews!',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.amber[200] : Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Company Name
            _buildLabel('Company Name', required: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('e.g., Google', isDark),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Company name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Website URL
            _buildLabel('Website', required: false),
            const SizedBox(height: 8),
            TextFormField(
              controller: _websiteController,
              decoration: _inputDecoration('e.g., google.com', isDark),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            // LinkedIn URL
            _buildLabel('LinkedIn Page', required: false),
            const SizedBox(height: 8),
            TextFormField(
              controller: _linkedInController,
              decoration: _inputDecoration('e.g., linkedin.com/company/google', isDark),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            // Industry Dropdown
            _buildLabel('Industry', required: true),
            const SizedBox(height: 8),
            _buildIndustryDropdown(isDark, customIndustriesAsync),

            // Custom Industry (visible when "Other" selected)
            if (_selectedIndustry == Industry.other) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customIndustryController,
                decoration: _inputDecoration('Type your industry...', isDark),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (_selectedIndustry == Industry.other && 
                      (value == null || value.trim().isEmpty)) {
                    return 'Please specify the industry';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),

            // Notes
            _buildLabel('Notes', required: false),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: _inputDecoration('Why is this company interesting to you?', isDark),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditMode ? 'Save Changes' : 'Add Company',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {required bool required}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0077B5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildIndustryDropdown(bool isDark, AsyncValue<List<String>> customIndustriesAsync) {
    // Build list of all industries including custom ones
    final customIndustries = customIndustriesAsync.hasValue ? customIndustriesAsync.value! : <String>[];

    return DropdownButtonFormField<Industry>(
      value: _selectedIndustry,
      decoration: _inputDecoration('', isDark),
      dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      items: Industry.values.map((industry) {
        return DropdownMenuItem(
          value: industry,
          child: Text(
            industry.displayName,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedIndustry = value);
        }
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(targetCompaniesControllerProvider.notifier);

      if (widget.isEditMode) {
        // Update existing company
        final updated = widget.company!.copyWith(
          companyName: _nameController.text.trim(),
          websiteUrl: _websiteController.text.trim().isNotEmpty 
              ? _websiteController.text.trim() 
              : null,
          linkedInUrl: _linkedInController.text.trim().isNotEmpty 
              ? _linkedInController.text.trim() 
              : null,
          industry: _selectedIndustry,
          customIndustry: _selectedIndustry == Industry.other 
              ? _customIndustryController.text.trim() 
              : null,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        );

        final success = await controller.updateCompany(updated);
        if (success && mounted) {
          Navigator.pop(context);
          _showSuccessSnackbar('Company updated');
        }
      } else {
        // Add new company
        final id = await controller.addCompany(
          companyName: _nameController.text.trim(),
          websiteUrl: _websiteController.text.trim().isNotEmpty 
              ? _websiteController.text.trim() 
              : null,
          linkedInUrl: _linkedInController.text.trim().isNotEmpty 
              ? _linkedInController.text.trim() 
              : null,
          industry: _selectedIndustry,
          customIndustry: _selectedIndustry == Industry.other 
              ? _customIndustryController.text.trim() 
              : null,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
          sourceJobId: widget.sourceJobId,
        );

        if (id != null && mounted) {
          Navigator.pop(context);
          _showSuccessSnackbar('Company added');
        } else if (mounted) {
          // Check for "already exists" error
          final state = ref.read(targetCompaniesControllerProvider);
          if (state.hasError && state.error.toString().contains('already exists')) {
            _showErrorSnackbar('This company is already in your list');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
