import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:job_tracker/services/job_parsing_service.dart';
import 'package:job_tracker/features/target_companies/add_to_target_prompt.dart';
import 'jobs_provider.dart';
import 'job_model.dart';

class AddJobModal extends ConsumerStatefulWidget {
  final JobModel? jobToEdit;
  
  const AddJobModal({super.key, this.jobToEdit});

  @override
  ConsumerState<AddJobModal> createState() => _AddJobModalState();
}

class _AddJobModalState extends ConsumerState<AddJobModal> {
  final _linkController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _hiringNameController = TextEditingController();
  final _hiringUrlController = TextEditingController();
  final _countryController = TextEditingController(); 
  final _descController = TextEditingController();
  
  String? _selectedSource;
  String? _selectedWorkMode; 
  List<String> _keywords = [];
  final List<String> _sourceOptions = [
    'LinkedIn',
    'Indeed',
    'Bayt',
    'Zoho Recruit',
    'Professional Pyramid',
    'Career Page',
    'Other'
  ];

  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  String? _error;
  
  Uint8List? _cvBytes;
  String? _cvFileName;
  
  List<String> _responsibilities = [];
  List<String> _qualifications = [];
  List<String> _benefits = [];

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _linkController.text = job.url;
      _companyController.text = job.company;
      _roleController.text = job.role;
      _hiringNameController.text = job.hiringManagerName ?? '';
      _hiringUrlController.text = job.hiringManagerUrl ?? '';
      _countryController.text = job.country ?? '';
      _selectedWorkMode = job.workMode;
      _descController.text = job.description ?? '';
      _keywords = List.from(job.keywords ?? []);
      _responsibilities = List.from(job.responsibilities ?? []);
      _qualifications = List.from(job.qualifications ?? []);
      _benefits = List.from(job.benefits ?? []);
      _hasAnalyzed = true;
      
      if (_sourceOptions.contains(job.source)) {
        _selectedSource = job.source;
      } else {
        _selectedSource = 'Other'; 
      }
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _hiringNameController.dispose();
    _hiringUrlController.dispose();
    _countryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _analyzeLink() async {
    final url = _linkController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final service = JobParsingService();
      final data = await service.parseJobUrl(url);
      
      if (mounted) {
        setState(() {
          // Populate fields if they are empty or we have better data
          if (_companyController.text.isEmpty && data.company != null) {
            _companyController.text = data.company!;
          }
          if (_roleController.text.isEmpty && data.role != null) {
            _roleController.text = data.role!;
          }
          if (_countryController.text.isEmpty && data.country != null) {
            _countryController.text = data.country!;
          }
          if (_descController.text.isEmpty && data.description != null) {
            _descController.text = data.description!;
          }
          
          if (data.source != null) {
            if (_sourceOptions.contains(data.source)) {
              _selectedSource = data.source;
            } else {
              _selectedSource = 'Other';
            }
          }
          
          if (data.responsibilities.isNotEmpty) {
            _responsibilities = List.from(data.responsibilities);
          }
          
          if (data.qualifications.isNotEmpty) {
            _qualifications = List.from(data.qualifications);
          }
          
          if (data.benefits.isNotEmpty) {
            _benefits = List.from(data.benefits);
          }
          
          if (data.keywords.isNotEmpty) {
            _keywords = List.from(data.keywords);
          }
          
          _hasAnalyzed = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to analyze link: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.jobToEdit != null ? 'Edit Job' : 'Add New Job',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Link Input
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: 'Job Post Link',
                hintText: 'https://linkedin.com/jobs/...',
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: _isAnalyzing
                    ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator())
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome, color: Colors.indigo),
                        onPressed: _analyzeLink,
                        tooltip: 'Auto-fill from Link',
                      ),
              ),
            ),
            
            if (_hasAnalyzed || _companyController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Job Role'),
              ),
              const SizedBox(height: 16),
              
              // Source Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(labelText: 'Job Board'),
                items: _sourceOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSource = newValue;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              Text(
                "Hiring Details (Stage 2)",
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hiringNameController,
                decoration: const InputDecoration(labelText: 'Hiring Manager Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hiringUrlController,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile URL'),
              ),
              const SizedBox(height: 16),
              
              // Work Mode & Country
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedWorkMode,
                      decoration: const InputDecoration(labelText: 'Work Mode'),
                      items: ['Remote', 'Hybrid', 'On-site']
                          .map((m) => DropdownMenuItem(value: m.toLowerCase(), child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedWorkMode = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country (e.g. US, AE)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Advanced Details
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text("Job Details"),
                  initiallyExpanded: _hasAnalyzed,
                  children: [
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Job Description / Highlights',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _keywords.join(', '),
                      decoration: const InputDecoration(labelText: 'Keywords (comma separated)'),
                      onChanged: (val) {
                        _keywords = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _responsibilities.join('\n'),
                      decoration: const InputDecoration(labelText: 'Responsibilities (one per line)'),
                      maxLines: 4,
                      onChanged: (val) {
                        _responsibilities = val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _qualifications.join('\n'),
                      decoration: const InputDecoration(labelText: 'Qualifications (one per line)'),
                      maxLines: 4,
                      onChanged: (val) {
                        _qualifications = val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _benefits.join('\n'),
                      decoration: const InputDecoration(labelText: 'Benefits (one per line)'),
                      maxLines: 4,
                      onChanged: (val) {
                        _benefits = val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.jobToEdit != null ? 'Save Changes' : 'Add to Tracker'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role/Position is required'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (widget.jobToEdit != null) {
      ref.read(jobsControllerProvider.notifier).editJob(
        jobId: widget.jobToEdit!.id,
        company: _companyController.text,
        role: _roleController.text,
        url: _linkController.text,
        status: widget.jobToEdit!.status,
        appliedDate: widget.jobToEdit!.appliedDate,
        source: _selectedSource,
        hiringManagerName: _hiringNameController.text.isEmpty ? null : _hiringNameController.text,
        hiringManagerUrl: _hiringUrlController.text.isEmpty ? null : _hiringUrlController.text,
        country: _countryController.text.isEmpty ? null : _countryController.text,
        workMode: _selectedWorkMode,
        description: _descController.text.isEmpty ? null : _descController.text,
        keywords: _keywords,
        responsibilities: _responsibilities,
        qualifications: _qualifications,
        benefits: _benefits,
        cvBytes: _cvBytes,
        cvFileName: _cvFileName,
        existingCvUrl: widget.jobToEdit!.cvUrl,
      );
    } else {
      ref.read(jobsControllerProvider.notifier).addJob(
        company: _companyController.text,
        role: _roleController.text,
        url: _linkController.text,
        source: _selectedSource,
        hiringManagerName: _hiringNameController.text.isEmpty ? null : _hiringNameController.text,
        hiringManagerUrl: _hiringUrlController.text.isEmpty ? null : _hiringUrlController.text,
        country: _countryController.text.isEmpty ? null : _countryController.text,
        workMode: _selectedWorkMode,
        description: _descController.text.isEmpty ? null : _descController.text,
        keywords: _keywords,
        responsibilities: _responsibilities,
        qualifications: _qualifications,
        benefits: _benefits,
        cvBytes: _cvBytes,
        cvFileName: _cvFileName,
      );
    }
    
    // Close the modal first
    if (mounted) {
      Navigator.pop(context);
    
      // Show target company prompt for new jobs only
      if (widget.jobToEdit == null) {
        final companyName = _companyController.text.trim();
        if (companyName.isNotEmpty) {
          // Small delay to let the modal close animation complete
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            await showAddToTargetCompaniesPrompt(
              context: context,
              ref: ref,
              companyName: companyName,
            );
          }
        }
      }
    }
  }
}
