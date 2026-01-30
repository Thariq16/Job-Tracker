import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Data extracted from a job URL
class ParsedJobData {
  final String? company;
  final String? role;
  final String? description;
  final String? source;
  final String? sourceJobId;
  final String? originalUrl;
  final String? country;
  final String? workMode;
  final List<String> keywords;
  final List<String> responsibilities;
  final List<String> qualifications;
  final List<String> benefits;

  ParsedJobData({
    this.company,
    this.role,
    this.description,
    this.source,
    this.sourceJobId,
    this.originalUrl,
    this.country,
    this.workMode,
    this.keywords = const [],
    this.responsibilities = const [],
    this.qualifications = const [],
    this.benefits = const [],
  });
  
  ParsedJobData copyWith({
    String? company,
    String? role,
    String? description,
    String? source,
    String? sourceJobId,
    String? originalUrl,
    String? country,
    String? workMode,
    List<String>? keywords,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? benefits,
  }) {
    return ParsedJobData(
      company: company ?? this.company,
      role: role ?? this.role,
      description: description ?? this.description,
      source: source ?? this.source,
      sourceJobId: sourceJobId ?? this.sourceJobId,
      originalUrl: originalUrl ?? this.originalUrl,
      country: country ?? this.country,
      workMode: workMode ?? this.workMode,
      keywords: keywords ?? this.keywords,
      responsibilities: responsibilities ?? this.responsibilities,
      qualifications: qualifications ?? this.qualifications,
      benefits: benefits ?? this.benefits,
    );
  }

  /// Check if this is from a recognized job board
  bool get isFromJobBoard => source != null && source != 'Career Page';
  
  /// Get direct link to view job on original platform
  String? get viewOnSourceUrl => originalUrl;
}

/// Service to parse job posting URLs and extract metadata
class JobParsingService {
  /// Parse a job URL and extract available metadata
  Future<ParsedJobData> parseJobUrl(String url) async {
    String? source;
    String? sourceJobId;
    String? country;
    
    // Initial basic parsing
    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();
      
      // Detect source platform
      if (host.contains('linkedin')) {
        source = 'LinkedIn';
        sourceJobId = _extractLinkedInJobId(uri);
      } else if (host.contains('indeed')) {
        source = 'Indeed';
        sourceJobId = _extractIndeedJobId(uri);
      } else if (host.contains('bayt')) {
        source = 'Bayt';
        sourceJobId = _extractBaytJobId(uri);
      } else if (host.contains('glassdoor')) {
        source = 'Glassdoor';
      } else if (host.contains('naukrigulf')) {
        source = 'NaukriGulf';
      } else if (host.contains('gulftalent')) {
        source = 'GulfTalent';
      } else if (host.contains('dubizzle') || host.contains('bayut')) {
        source = 'Dubizzle';
      } else if (host.contains('monster')) {
        source = 'Monster';
      } else if (host.contains('ziprecruiter')) {
        source = 'ZipRecruiter';
      } else if (host.contains('lever.co')) {
        source = 'Lever';
      } else if (host.contains('greenhouse.io')) {
        source = 'Greenhouse';
      } else if (host.contains('workday')) {
        source = 'Workday';
      } else if (host.contains('rippling')) {
        source = 'Rippling';
      } else if (host.contains('zohorecruit')) {
        source = 'Zoho Recruit';
        // Extract job ID from URL path (e.g., /jobs/Careers/838790000000542408/...)
        final zohoMatch = RegExp(r'/jobs/[^/]+/(\d+)/').firstMatch(uri.path);
        sourceJobId = zohoMatch?.group(1);
      } else if (host.contains('workable.com') || host.contains('workable')) {
        source = 'Workable';
        // Extract job ID from URL path (e.g., /company/j/E535316205)
        final workableMatch = RegExp(r'/j/([A-Z0-9]+)').firstMatch(uri.path);
        sourceJobId = workableMatch?.group(1);
      } else if (host.contains('jobs.') || host.contains('careers.') || path.contains('/careers') || path.contains('/jobs')) {
        source = 'Career Page';
      } else {
        source = 'Other';
      }

      // Detect country from URL
      country = _detectCountry(uri);
      
    } catch (_) {
      // URL parsing failed - return minimal data
    }
    
    final initialData = ParsedJobData(
      source: source,
      sourceJobId: sourceJobId,
      originalUrl: url.trim(),
      country: country,
    );
    
    // Try Workable public API first (returns structured JSON data)
    if (source == 'Workable' && sourceJobId != null) {
      try {
        final workableData = await _fetchWorkableJobData(url, sourceJobId);
        if (workableData != null) {
          return workableData.copyWith(
            source: source,
            sourceJobId: sourceJobId,
            originalUrl: url.trim(),
          );
        }
      } catch (e) {
        print('Failed to fetch Workable API: $e');
      }
    }
    
    // Try to fetch specific content for supported sources
    // Note: Zoho uses JS rendering but we can still get meta tags
    if (source == 'Zoho Recruit' || source == 'Rippling' || source == 'Workable' || source == 'Career Page' || source == 'Other') {
       try {
         final content = await _fetchJobPage(url);
         if (content != null) {
           return _parseJobContent(content, initialData);
         }
       } catch (e) {
         print('Failed to fetch job content: $e');
       }
    }

    return initialData;
  }
  
  /// Fetch job data from Workable's public API
  /// API endpoint: https://www.workable.com/api/accounts/{subdomain}
  Future<ParsedJobData?> _fetchWorkableJobData(String url, String jobId) async {
    try {
      // Extract subdomain from URL (e.g., "algooru" from apply.workable.com/algooru/j/...)
      final uri = Uri.parse(url.trim());
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return null;
      
      final subdomain = pathSegments[0]; // First path segment is the company subdomain
      final apiUrl = 'https://www.workable.com/api/accounts/$subdomain';
      
      print('=== WORKABLE API DEBUG ===');
      print('Subdomain: $subdomain');
      print('API URL: $apiUrl');
      print('Looking for job ID: $jobId');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        print('Workable API failed with status: ${response.statusCode}');
        return null;
      }
      
      final data = json.decode(response.body) as Map<String, dynamic>;
      final companyName = data['name'] as String?;
      final companyDesc = data['description'] as String?;
      final jobs = data['jobs'] as List<dynamic>?;
      
      if (jobs == null) return null;
      
      // Find the matching job by shortcode
      Map<String, dynamic>? matchingJob;
      for (final job in jobs) {
        if (job['shortcode'] == jobId) {
          matchingJob = job as Map<String, dynamic>;
          break;
        }
      }
      
      if (matchingJob == null) {
        print('Job $jobId not found in API response');
        return null;
      }
      
      print('Found matching job: ${matchingJob['title']}');
      
      // Build description from available fields
      final descParts = <String>[];
      if (companyDesc != null && companyDesc.isNotEmpty) {
        // Strip HTML tags from company description
        final cleanDesc = companyDesc.replaceAll(RegExp(r'<[^>]*>'), '');
        descParts.add(cleanDesc);
      }
      if (matchingJob['department'] != null) {
        descParts.add('Department: ${matchingJob['department']}');
      }
      if (matchingJob['employment_type'] != null) {
        descParts.add('Employment Type: ${matchingJob['employment_type']}');
      }
      if (matchingJob['experience'] != null) {
        descParts.add('Experience Level: ${matchingJob['experience']}');
      }
      if (matchingJob['industry'] != null) {
        descParts.add('Industry: ${matchingJob['industry']}');
      }
      
      // Determine work mode
      String? workMode;
      if (matchingJob['telecommuting'] == true) {
        workMode = 'Remote';
      } else {
        workMode = 'On-site';
      }
      
      // Build location string
      String? jobCountry = matchingJob['country'] as String?;
      final city = matchingJob['city'] as String?;
      if (city != null && jobCountry != null) {
        descParts.add('Location: $city, $jobCountry');
      }
      
      return ParsedJobData(
        company: companyName,
        role: matchingJob['title'] as String?,
        description: descParts.join('\n\n'),
        country: jobCountry,
        workMode: workMode,
        keywords: _extractKeywordsFromWorkable(matchingJob),
      );
    } catch (e) {
      print('Error fetching Workable API: $e');
      return null;
    }
  }
  
  /// Extract keywords from Workable job data
  List<String> _extractKeywordsFromWorkable(Map<String, dynamic> job) {
    final keywords = <String>[];
    
    // Add employment type as keyword
    if (job['employment_type'] != null) {
      keywords.add(job['employment_type'].toString().toLowerCase());
    }
    
    // Add experience level
    if (job['experience'] != null) {
      keywords.add(job['experience'].toString().toLowerCase());
    }
    
    // Add industry
    if (job['industry'] != null) {
      keywords.add(job['industry'].toString().toLowerCase());
    }
    
    // Add department (clean emoji)
    if (job['department'] != null) {
      final dept = job['department'].toString().replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
      if (dept.isNotEmpty) keywords.add(dept);
    }
    
    return keywords;
  }
  
  Future<String?> _fetchJobPage(String url) async {
    // List of CORS proxies to try (in order of preference)
    final corsProxies = kIsWeb ? [
      'https://api.codetabs.com/v1/proxy?quest=',          // codetabs proxy
      'https://thingproxy.freeboard.io/fetch/',            // freeboard proxy
      'https://api.allorigins.win/raw?url=',               // allorigins (backup)
    ] : [url]; // Direct URL for non-web platforms
    
    print('=== FETCH DEBUG ===');
    print('Original URL: $url');
    print('Is Web: $kIsWeb');
    
    for (final proxyBase in corsProxies) {
      try {
        final targetUrl = kIsWeb 
            ? proxyBase + Uri.encodeComponent(url) 
            : url;
        
        print('Trying proxy: $proxyBase');
        print('Target URL: $targetUrl');
        
        final response = await http.get(
          Uri.parse(targetUrl),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ).timeout(const Duration(seconds: 15));
        
        print('Response status: ${response.statusCode}');
        print('Response body length: ${response.body.length}');
        
        if (response.statusCode == 200) {
          // Check if we got actual HTML content
          if (response.body.contains('<html') || response.body.contains('<!DOCTYPE')) {
            print('Got valid HTML response from proxy');
            return response.body;
          } else {
            print('Response does not appear to be HTML, trying next proxy...');
          }
        } else {
          print('Failed with status ${response.statusCode}, trying next proxy...');
        }
      } catch (e) {
        print('Error with proxy: $e, trying next...');
      }
    }
    
    print('All proxies failed');
    return null;
  }
  
  ParsedJobData _parseJobContent(String htmlContent, ParsedJobData baseData) {
    final document = html_parser.parse(htmlContent);
    
    String? title = baseData.role;
    String? company = baseData.company;
    String? description = baseData.description;
    List<String> responsibilities = List.from(baseData.responsibilities);
    List<String> qualifications = List.from(baseData.qualifications);
    List<String> benefits = List.from(baseData.benefits);
    List<String> keywords = List.from(baseData.keywords);
    
    // Debug logging
    print('=== JOB PARSING DEBUG ===');
    print('Source: ${baseData.source}');
    print('HTML length: ${htmlContent.length}');
    
    // 1. Title Heuristics - prioritize meta tags for JS-heavy sites
    if (title == null) {
      final h1 = document.querySelector('h1')?.text.trim();
      final ogTitle = document.querySelector('meta[property="og:title"]')?.attributes['content'];
      final titleTag = document.querySelector('title')?.text.trim();
      
      print('h1: $h1');
      print('og:title: $ogTitle');
      print('title tag: $titleTag');
      
      // For JS-rendered sites (Workable, Zoho), prefer og:title or title tag
      // since h1 might just be loader content
      String? rawTitle;
      final isJsRenderedSite = baseData.source == 'Workable' || baseData.source == 'Zoho Recruit';
      
      if (isJsRenderedSite) {
        // Prefer meta tags for JS-heavy sites
        rawTitle = ogTitle ?? titleTag ?? h1;
      } else {
        // Try h1 first for traditional sites
        rawTitle = (h1 != null && h1.isNotEmpty) ? h1 : (ogTitle ?? titleTag);
      }
      
      // Parse title - handle formats like "Role - Company" or "Role | Company"
      if (rawTitle != null && rawTitle.isNotEmpty) {
        // Workable format: "Marketing Intern - AlGooru"
        // Zoho Recruit format: "500 Global - Eurasia Marketing Coordinator - Remote Job"
        if (rawTitle.contains(' - ')) {
          final parts = rawTitle.split(' - ');
          if (parts.length >= 2) {
            // Workable: Role - Company (first part is role, last is company)
            // Zoho: Company - Role - Type (first is company, second is role)
            if (baseData.source == 'Workable') {
              title = parts[0].trim(); // First part is role
              if (company == null && parts.length > 1) {
                company = parts.last.trim(); // Last part is company
              }
            } else {
              // Zoho format: Company - Role - Type
              title = parts[1].trim(); // Second part is role
              if (company == null && parts[0].isNotEmpty) {
                company = parts[0].trim();
              }
            }
          }
        } else if (rawTitle.contains(' | ')) {
          final parts = rawTitle.split(' | ');
          title = parts[0].trim();
          if (company == null && parts.length > 1) {
            company = parts.last.trim();
          }
        } else {
          title = rawTitle;
        }
      }
      
      print('Extracted title: $title');
    }
    
    // 2. Company Heuristics - check multiple sources
    if (company == null) {
       company = document.querySelector('meta[property="og:site_name"]')?.attributes['content'];
       print('og:site_name: $company');
    }
    
    // 2b. For Workable, try to extract company from subdomain meta tag
    if (company == null && baseData.source == 'Workable') {
      final subdomain = document.querySelector('meta[name="subdomain"]')?.attributes['content'];
      if (subdomain != null && subdomain.isNotEmpty) {
        // Capitalize the subdomain as company name
        company = subdomain[0].toUpperCase() + subdomain.substring(1);
      }
    }
    
    // 2c. Look for "Company: xyz" pattern in page text
    if (company == null) {
      final pageText = document.body?.text ?? '';
      final companyMatch = RegExp(r'Company[:\s]+([A-Za-z0-9\s&]+?)(?:\n|Location|Date|Job)', caseSensitive: false).firstMatch(pageText);
      if (companyMatch != null) {
        company = companyMatch.group(1)?.trim();
      }
    }
    
    // 3. Section Keywords for parsing
    final sectionKeywords = {
      'responsibilities': [
        'responsibilities', 
        'key responsibilities', 
        'what you\'ll do', 
        'what you will do', 
        'duties',
        'your role',
        'job duties',
      ],
      'qualifications': [
        'qualifications', 
        'requirements', 
        'what we\'re looking for',
        'who you are', 
        'what we look for', 
        'required skills',
        'must have',
        'experience required',
        'years of experience',
      ],
      'benefits': [
        'benefits',
        'what we offer',
        'perks',
        'why join us',
        'compensation',
        'what you\'ll get',
      ],
      'description': [
        'about the role',
        'job description',
        'overview',
        'about this job',
        'position summary',
        'job purpose',
      ],
    };

    // 4. Find job description container first (usually largest text block)
    String? fullDescription;
    final descContainer = document.querySelectorAll('[class*="description"], [class*="job-details"], [class*="content"], main, article')
      .fold<dom.Element?>(null, (best, current) {
         if (best == null) return current;
         return (current.text.length > best.text.length) ? current : best;
      });
    
    if (descContainer != null) {
      fullDescription = descContainer.text.trim();
    }

    // 5. Iterate over all potential section headers
    for (final element in document.querySelectorAll('h2, h3, h4, h5, strong, b, p')) {
      final text = element.text.toLowerCase().trim();
      
      // Skip very long text (not headers)
      if (text.length > 100) continue;
      
      // Check for Responsibilities
      if (responsibilities.isEmpty && _matchesAny(text, sectionKeywords['responsibilities']!)) {
        final list = _findFollowingList(element);
        if (list.isNotEmpty) responsibilities = list;
      }
      
      // Check for Qualifications
      if (qualifications.isEmpty && _matchesAny(text, sectionKeywords['qualifications']!)) {
        final list = _findFollowingList(element);
        if (list.isNotEmpty) qualifications = list;
      }
      
      // Check for Benefits
      if (benefits.isEmpty && _matchesAny(text, sectionKeywords['benefits']!)) {
        final list = _findFollowingList(element);
        if (list.isNotEmpty) benefits = list;
      }
      
      // Check for Description section
      if (description == null && _matchesAny(text, sectionKeywords['description']!)) {
        final descText = _findFollowingText(element);
        if (descText.isNotEmpty) description = descText;
      }
    }
    
    // 6. Fallback for description: use og:description or full text
    if (description == null) {
      description = document.querySelector('meta[property="og:description"]')?.attributes['content'];
    }
    if (description == null && fullDescription != null) {
      // Truncate to a reasonable size
      description = fullDescription.length > 2000 
          ? fullDescription.substring(0, 2000) + '...'
          : fullDescription;
    }

    // 7. Extract Keywords from description using common tech/skill terms
    if (keywords.isEmpty && fullDescription != null) {
      keywords = _extractKeywords(fullDescription);
    }
    
    return baseData.copyWith(
      role: title,
      company: company,
      description: description,
      responsibilities: responsibilities,
      qualifications: qualifications,
      benefits: benefits,
      keywords: keywords,
    );
  }
  
  String _findFollowingText(dom.Element header) {
    // Look for next paragraph or text element
    var sibling = header.nextElementSibling;
    while (sibling != null) {
      if (sibling.localName == 'p' || sibling.localName == 'div') {
        final text = sibling.text.trim();
        if (text.length > 50) return text;
      }
      if (['h1', 'h2', 'h3', 'h4'].contains(sibling.localName)) break;
      sibling = sibling.nextElementSibling;
    }
    return '';
  }
  
  List<String> _extractKeywords(String text) {
    // Common tech/business keywords to look for
    final commonKeywords = [
      'python', 'java', 'javascript', 'typescript', 'sql', 'react', 'angular', 'vue',
      'node', 'flutter', 'dart', 'swift', 'kotlin', 'go', 'rust', 'c++', 'c#',
      'aws', 'azure', 'gcp', 'docker', 'kubernetes', 'ci/cd', 'devops', 'agile', 'scrum',
      'machine learning', 'ai', 'data science', 'analytics', 'tableau', 'power bi',
      'product management', 'project management', 'stakeholder', 'strategy',
      'leadership', 'communication', 'collaboration', 'problem-solving',
      'saas', 'b2b', 'b2c', 'crm', 'erp', 'api', 'rest', 'graphql',
      'figma', 'sketch', 'ux', 'ui', 'design', 'research',
      'excel', 'powerpoint', 'jira', 'confluence', 'slack', 'notion',
      'fintech', 'healthtech', 'edtech', 'startup', 'enterprise',
      // Telecom / IT infrastructure keywords
      'oss', 'bss', 'telecom', 'networking', 'infrastructure', 'integration',
      'cybersecurity', 'data governance', 'compliance', 'maintenance', 'deployment',
    ];
    
    final lowerText = text.toLowerCase();
    final foundKeywords = <String>[];
    
    for (final keyword in commonKeywords) {
      if (lowerText.contains(keyword) && !foundKeywords.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }
    
    // Limit to top 10 keywords
    return foundKeywords.take(10).toList();
  }
  
  bool _matchesAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }
  
  List<String> _findFollowingList(dom.Element header) {
    // Look at siblings
    var sibling = header.nextElementSibling;
    while (sibling != null) {
      if (sibling.localName == 'ul' || sibling.localName == 'ol') {
        return sibling.children.map((li) => li.text.trim()).where((s) => s.isNotEmpty).toList();
      }
      // Stop if we hit another header
      if (['h1', 'h2', 'h3', 'h4'].contains(sibling.localName)) {
        break;
      }
      sibling = sibling.nextElementSibling;
    }
    
    // Look at parent's siblings if header is wrapped
    if (header.parent != null) {
        var parentSibling = header.parent!.nextElementSibling;
        while (parentSibling != null) {
             if (parentSibling.localName == 'ul' || parentSibling.localName == 'ol') {
                return parentSibling.children.map((li) => li.text.trim()).where((s) => s.isNotEmpty).toList();
             }
             if (['h1', 'h2', 'h3', 'h4'].contains(parentSibling.localName)) break;
             parentSibling = parentSibling.nextElementSibling;
        }
    }
    
    return [];
  }

  /// Extract job ID from LinkedIn URL
  /// Formats:
  /// - https://www.linkedin.com/jobs/view/12345678
  /// - https://www.linkedin.com/jobs/view/job-title-at-company-12345678
  /// - https://linkedin.com/jobs/collections/recommended/?currentJobId=12345678
  String? _extractLinkedInJobId(Uri uri) {
    final path = uri.path;
    
    // Check path for /jobs/view/ID pattern
    final viewMatch = RegExp(r'/jobs/view/(?:[\w-]+-)?(\d+)').firstMatch(path);
    if (viewMatch != null) {
      return viewMatch.group(1);
    }
    
    // Check query params for currentJobId
    final queryJobId = uri.queryParameters['currentJobId'];
    if (queryJobId != null) {
      return queryJobId;
    }
    
    return null;
  }

  /// Extract job ID from Indeed URL
  /// Format: https://www.indeed.com/viewjob?jk=abc123
  String? _extractIndeedJobId(Uri uri) {
    return uri.queryParameters['jk'];
  }

  /// Extract job ID from Bayt URL
  /// Format: https://www.bayt.com/en/uae/jobs/job-title-12345/
  String? _extractBaytJobId(Uri uri) {
    final match = RegExp(r'-(\d+)/?$').firstMatch(uri.path);
    return match?.group(1);
  }

  /// Detect country from URL patterns
  String? _detectCountry(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    
    // Country code mappings
    final countryPatterns = {
      'ae': ['ae', 'uae', 'dubai', 'abudhabi'],
      'sa': ['sa', 'saudi', 'ksa'],
      'us': ['us', 'usa'],
      'uk': ['uk', 'gb', 'london'],
      'in': ['in', 'india'],
      'qa': ['qa', 'qatar', 'doha'],
      'kw': ['kw', 'kuwait'],
      'bh': ['bh', 'bahrain'],
      'om': ['om', 'oman'],
      'eg': ['eg', 'egypt', 'cairo'],
    };
    
    for (final entry in countryPatterns.entries) {
      for (final pattern in entry.value) {
        // Prepare patterns for path matching to avoid partial words (e.g. 'in' in 'login')
        final pathStr = '/${path.replaceAll(RegExp(r'^/|/$'), '')}/'; // Ensure wrapped in slashes
        
        if (host.contains('.$pattern') || 
            host.endsWith('.$pattern') ||
            host.startsWith('$pattern.') || 
            pathStr.contains('/$pattern/') ||
            pathStr.contains('-$pattern/') ||
            pathStr.contains('/$pattern-') ||
            pathStr.contains('-$pattern-')) {
          return entry.key.toUpperCase();
        }
      }
    }
    
    return null;
  }

  /// Check if a string looks like a job URL
  bool isValidJobUrl(String text) {
    try {
      final uri = Uri.parse(text.trim());
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}
