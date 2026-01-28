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
  });

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

    return ParsedJobData(
      source: source,
      sourceJobId: sourceJobId,
      originalUrl: url.trim(),
      country: country,
    );
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
        if (host.contains('.$pattern') || 
            host.endsWith('.$pattern') ||
            path.contains('/$pattern/') ||
            path.startsWith('/$pattern/')) {
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
