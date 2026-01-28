import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

/// Parsed job data from URL
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
  static const _techKeywords = [
    'flutter', 'dart', 'react', 'typescript', 'javascript', 'python', 'java', 'kotlin', 'swift',
    'aws', 'firebase', 'azure', 'docker', 'kubernetes', 'sql', 'nosql', 'agile', 'scrum',
    'product management', 'roadmap', 'jira', 'figma', 'analytics'
  ];

  /// Parse job details from a URL
  Future<ParsedJobData> parseJobUrl(String url) async {
    String? source;
    String? country;
    String? workMode;

    // 1. URL Analysis
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();

      if (host.contains('linkedin')) source = 'LinkedIn';
      else if (host.contains('indeed')) source = 'Indeed';
      else if (host.contains('bayt')) source = 'Bayt';
      else if (host.contains('professionalpyramid')) source = 'Professional Pyramid';
      else source = 'Career Page';

      if (path.contains('/ae/') || host.endsWith('.ae')) country = 'AE';
      else if (path.contains('/us/') || host.endsWith('.com')) country = 'US';
      else if (path.contains('/uk/') || host.endsWith('.co.uk')) country = 'UK';
      else if (path.contains('/sa/') || host.endsWith('.sa')) country = 'SA';
    } catch (_) {}

    // 2. Fetch Content
    try {
      final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final bodyText = document.body?.text ?? '';
        final fullTextLower = bodyText.toLowerCase();

        // 3. Metadata Extraction
        String? title = document.querySelector('meta[property="og:title"]')?.attributes['content'];
        String? company = document.querySelector('meta[property="og:site_name"]')?.attributes['content'];
        String? description = document.querySelector('meta[property="og:description"]')?.attributes['content'];

        if (title == null || title.isEmpty) title = document.querySelector('title')?.text;

        // Cleanup Title
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
        if (fullTextLower.contains('remote')) workMode = 'remote';
        else if (fullTextLower.contains('hybrid')) workMode = 'hybrid';
        else if (fullTextLower.contains('on-site') || fullTextLower.contains('onsite')) workMode = 'onsite';

        // 5. Keywords
        final foundKeywords = <String>{};
        for (final keyword in _techKeywords) {
          if (fullTextLower.contains(keyword)) foundKeywords.add(keyword);
        }

        // 6. Section Extraction
        final responsibilities = _extractSection(document, ['responsibilities', 'what you will do', 'duties', 'role overview']);
        final qualifications = _extractSection(document, ['qualifications', 'requirements', 'skills', 'what you bring', 'who you are']);

        // 7. Description Enhancement
        if (description == null || description.length < 100) {
          final candidates = document.querySelectorAll('div.description, div.job-description, section.description, .job-details, article');
          if (candidates.isNotEmpty) {
            var bestText = '';
            for (var c in candidates) {
              if (c.text.length > bestText.length) bestText = c.text;
            }
            if (bestText.isNotEmpty) description = bestText;
          }

          if (description == null || description.length < 100) {
            description = bodyText.replaceAll(RegExp(r'\n\s*\n'), '\n\n').trim();
            if (description!.length > 800) description = '${description!.substring(0, 800)}...';
          }
        }

        return ParsedJobData(
          company: company,
          role: title,
          description: description?.trim(),
          source: source,
          country: country,
          workMode: workMode,
          keywords: foundKeywords.toList(),
          responsibilities: responsibilities,
          qualifications: qualifications,
        );
      }
    } catch (e) {
      // Return partial data from URL analysis
    }

    return ParsedJobData(source: source, country: country, workMode: workMode);
  }

  /// Extract list items from sections with matching headers
  List<String> _extractSection(dom.Document document, List<String> headers) {
    final List<String> items = [];
    final allElements = document.querySelectorAll('*');

    for (var element in allElements) {
      final text = element.text.toLowerCase().trim();
      if (headers.any((h) => text.contains(h) && text.length < 50)) {
        var sibling = element.nextElementSibling;
        int lookAhead = 0;

        while (sibling != null && lookAhead < 5) {
          if (sibling.localName == 'ul' || sibling.localName == 'ol') {
            for (var li in sibling.querySelectorAll('li')) {
              final liText = li.text.trim();
              if (liText.isNotEmpty) items.add('• $liText');
            }
            break;
          }
          sibling = sibling.nextElementSibling;
          lookAhead++;
        }

        if (items.isNotEmpty) break;
      }
    }

    return items;
  }
}
