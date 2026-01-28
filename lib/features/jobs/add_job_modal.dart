import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'jobs_provider.dart';
import 'job_model.dart'; // Import JobModel

class AddJobModal extends ConsumerStatefulWidget {
  final JobModel? jobToEdit; // Optional param for editing
  
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
  final _descController = TextEditingController(); // Description
  
  String? _selectedSource;
  String? _selectedWorkMode; 
  List<String> _keywords = []; // Mapped manually or via text field? Let's use chips.
  final List<String> _sourceOptions = [
    'LinkedIn',
    'Indeed',
    'Bayt',
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
      
      if (_sourceOptions.contains(job.source)) {
         _selectedSource = job.source;
      } else {
         _selectedSource = 'Other'; 
      }
    }
  }

  // Removed _pickCV

  Future<void> _analyzeLink() async {
    final url = _linkController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      // 1. Basic URL Analysis
      try {
        final uri = Uri.parse(url);
        final host = uri.host.toLowerCase();
        final path = uri.path.toLowerCase();
        
         if (host.contains('linkedin')) _selectedSource = 'LinkedIn';
        else if (host.contains('indeed')) _selectedSource = 'Indeed';
        else if (host.contains('bayt')) _selectedSource = 'Bayt';
        else if (host.contains('professionalpyramid')) _selectedSource = 'Professional Pyramid';
        else _selectedSource = 'Career Page'; 
        
        if (path.contains('/ae/') || host.endsWith('.ae')) _countryController.text = 'AE';
        else if (path.contains('/us/') || host.endsWith('.com')) _countryController.text = 'US';
        else if (path.contains('/uk/') || host.endsWith('.co.uk')) _countryController.text = 'UK';
        else if (path.contains('/sa/') || host.endsWith('.sa')) _countryController.text = 'SA';

      } catch (_) {}


      // 2. Fetch Content
      final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final bodyText = document.body?.text ?? '';
        final fullTextLower = bodyText.toLowerCase();

        // 3. Metadata Extraction (Title, Company, Description)
        String? title = document.querySelector('meta[property="og:title"]')?.attributes['content'];
        String? company = document.querySelector('meta[property="og:site_name"]')?.attributes['content'];
        String? description = document.querySelector('meta[property="og:description"]')?.attributes['content'];

        if (title == null || title.isEmpty) title = document.querySelector('title')?.text;

        if (title != null) {
          final separators = ['|', '-', '–', '•'];
          for (final sep in separators) {
             if (title!.contains(sep)) {
               title = title!.split(sep).first.trim();
               break; 
             }
          }
        }
        
        // 4. Work Mode
        if (fullTextLower.contains('remote')) _selectedWorkMode = 'remote';
        else if (fullTextLower.contains('hybrid')) _selectedWorkMode = 'hybrid';
        else if (fullTextLower.contains('on-site') || fullTextLower.contains('onsite')) _selectedWorkMode = 'onsite';

        // 5. Keywords
        final foundKeywords = <String>{};
        final commonTech = [
          'flutter', 'dart', 'react', 'typescript', 'javascript', 'python', 'java', 'kotlin', 'swift',
          'aws', 'firebase', 'azure', 'docker', 'kubernetes', 'sql', 'nosql', 'agile', 'scrum',
          'product management', 'roadmap', 'jira', 'figma', 'analytics'
        ];
        
        for (final keyword in commonTech) {
          if (fullTextLower.contains(keyword)) foundKeywords.add(keyword);
        }

        // 6. Detailed Section Extraction
        List<String> responsibilities = _extractSection(document, ['responsibilities', 'what you will do', 'duties', 'role overview']);
        List<String> qualifications = _extractSection(document, ['qualifications', 'requirements', 'skills', 'what you bring', 'who you are']);
        
        // 7. Semantic Description
        // If meta description is short, try to find the biggest text block
        if (description == null || description.length < 100) {
           // Look for classic job description containers
           final candidates = document.querySelectorAll('div.description, div.job-description, section.description, .job-details, article');
           if (candidates.isNotEmpty) {
             // Take the longest one
             var bestText = '';
             for (var c in candidates) {
               if (c.text.length > bestText.length) bestText = c.text;
             }
             if (bestText.isNotEmpty) description = bestText;
           }
           
           if (description == null || description.length < 100) {
             // Fallback: Clean up body text (removes scripts/styles implicitly by parser usually, but good to be safe)
             description = bodyText.replaceAll(RegExp(r'\n\s*\n'), '\n\n').trim();
             if (description!.length > 800) description = description!.substring(0, 800) + '...';
           }
        }
        
        // Clean description generally
        description = description?.trim();

        if (mounted) {
          setState(() {
            _companyController.text = company ?? '';
            _roleController.text = title ?? '';
            _descController.text = description ?? ''; 
            _keywords = foundKeywords.toList();
            _responsibilities = responsibilities;
            _qualifications = qualifications;
            _hasAnalyzed = true;
          });
        }
      } else {
        throw Exception('Failed to load page');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not fetch details. Please fill manually.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // Helper for Section Extraction
  List<String> _extractSection(parser.Document document, List<String> headers) {
    final List<String> items = [];
    
    // 1. Find the headers
    final allElements = document.querySelectorAll('*'); // Or specific tags like h1, h2, h3, h4, strong, p
    
    for (var element in allElements) {
       final text = element.text.toLowerCase().trim();
       if (headers.any((h) => text.contains(h) && text.length < 50)) {
          // Found a potential header!
          // Look at siblings or next elements
          var sibling = element.nextElementSibling;
          
          // Loop until we find a list or run out of relevant content
          int lookAhead = 0;
          while (sibling != null && lookAhead < 5) {
             if (sibling.localName == 'ul' || sibling.localName == 'ol') {
                // Found a list! Extract items
                for (var li in sibling.querySelectorAll('li')) {
                   final liText = li.text.trim();
                   if (liText.isNotEmpty) items.add('• $liText');
                }
                break; // Done with this section
             }
             sibling = sibling.nextElementSibling;
             lookAhead++;
          }
          
          if (items.isNotEmpty) break;
       }
    }
    
    return items;
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
            ).animate().fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 16),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Job Role'),
            ).animate().fadeIn().slideY(begin: 0.2),
             const SizedBox(height: 16),
            
            // Source Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSource,
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
            ).animate().fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: 16),
            // Stage 2 Fields
            Text("Hiring Details (Stage 2)", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
            
            // New Fields (Data 2.0)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedWorkMode,
                    decoration: const InputDecoration(labelText: 'Work Mode'),
                    items: ['Remote', 'Hybrid', 'On-site'].map((m) => DropdownMenuItem(value: m.toLowerCase(), child: Text(m))).toList(),
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
            
            // Advanced / Parsed Data
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text("Job Details (AI Parsed)"),
                initiallyExpanded: _hasAnalyzed,
                children: [
                   TextField(
                     controller: _descController,
                     decoration: const InputDecoration(labelText: 'Job Description / Highlights', alignLabelWithHint: true),
                     maxLines: 4,
                   ),
                   const SizedBox(height: 16),
                   // Keywords Editor (Simple String for MVP -> comma separated or chips? Let's simple comma field for now easy edit)
                   // But wait, our model uses List<String>. Let's do a text field that splits on comma.
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
                   )
                ],
              ),
            )
            
          ],

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_companyController.text.isEmpty || _roleController.text.isEmpty) {
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
                    cvBytes: _cvBytes,
                    cvFileName: _cvFileName,
                  );
                }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(widget.jobToEdit != null ? 'Save Changes' : 'Add to Tracker'),
          ),
           const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}
