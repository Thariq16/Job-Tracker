class ParsedJobData {
  final String? company;
  final String? role;
  final String? description;
  final String? source;
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
    this.country,
    this.workMode,
    this.keywords = const [],
    this.responsibilities = const [],
    this.qualifications = const [],
  });
}

class JobParsingService {
  Future<ParsedJobData> parseJobUrl(String url) async {
    String? source;
    String? country;
    
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      
      if (host.contains('linkedin')) {
        source = 'LinkedIn';
      } else if (host.contains('indeed')) {
        source = 'Indeed';
      } else if (host.contains('bayt')) {
        source = 'Bayt';
      } else {
        source = 'Career Page';
      }

      if (uri.path.contains('/ae/') || host.endsWith('.ae')) {
        country = 'AE';
      } else if (uri.path.contains('/us/') || host.endsWith('.com')) {
        country = 'US';
      }
    } catch (_) {
      // URL parsing failed
    }

    return ParsedJobData(
      source: source,
      country: country,
    );
  }
}
