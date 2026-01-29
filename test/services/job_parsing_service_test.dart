import 'package:flutter_test/flutter_test.dart';
import 'package:job_tracker/services/job_parsing_service.dart';

void main() {
  late JobParsingService service;

  setUp(() {
    service = JobParsingService();
  });

  group('JobParsingService', () {
    test('detects LinkedIn URLs correctly', () async {
      final scenarios = [
        (
          url: 'https://www.linkedin.com/jobs/view/3755448899',
          id: '3755448899',
        ),
        (
          url: 'https://www.linkedin.com/jobs/view/software-engineer-3755448899',
          id: '3755448899',
        ),
        (
          url: 'https://linkedin.com/jobs/collections/recommended/?currentJobId=3755448899',
          id: '3755448899',
        ),
      ];

      for (final scenario in scenarios) {
        final result = await service.parseJobUrl(scenario.url);
        expect(result.source, 'LinkedIn', reason: 'Failed source for ${scenario.url}');
        expect(result.sourceJobId, scenario.id, reason: 'Failed ID for ${scenario.url}');
      }
    });

    test('detects Indeed URLs correctly', () async {
      const url = 'https://www.indeed.com/viewjob?jk=12345abcde';
      final result = await service.parseJobUrl(url);
      
      expect(result.source, 'Indeed');
      expect(result.sourceJobId, '12345abcde');
    });

    test('detects Bayt URLs correctly', () async {
      const url = 'https://www.bayt.com/en/uae/jobs/senior-developer-67890/';
      final result = await service.parseJobUrl(url);
      
      expect(result.source, 'Bayt');
      expect(result.sourceJobId, '67890');
      expect(result.country, 'AE'); // UAE -> AE
    });

    test('detects platform names for other known boards', () async {
      final scenarios = {
        'https://www.glassdoor.com/job/123': 'Glassdoor',
        'https://www.naukrigulf.com/job/123': 'NaukriGulf',
        'https://www.gulftalent.com/job/123': 'GulfTalent',
        'https://dubai.dubizzle.com/jobs/123': 'Dubizzle',
        'https://www.monster.com/job/123': 'Monster',
        'https://www.ziprecruiter.com/job/123': 'ZipRecruiter',
        'https://jobs.lever.co/company/job': 'Lever',
        'https://boards.greenhouse.io/company/jobs/123': 'Greenhouse',
        'https://company.workday.com/job/123': 'Workday',
        'https://ats.rippling.com/mozn-ai/jobs/cacc8293-33e6-4a01-a387-8a878e77847c': 'Rippling',
      };

      for (final entry in scenarios.entries) {
        final result = await service.parseJobUrl(entry.key);
        expect(result.source, entry.value, reason: 'Failed detection for ${entry.key}');
      }
    });

    test('detects generic career pages', () async {
      final urls = [
        'https://jobs.company.com/role',
        'https://careers.company.com/role',
        'https://company.com/careers/role',
        'https://company.com/jobs/role',
      ];

      for (final url in urls) {
        final result = await service.parseJobUrl(url);
        expect(result.source, 'Career Page', reason: 'Failed detection for $url');
      }
    });

    test('handles unknown sources gracefully', () async {
      const url = 'https://example.com/some/random/page';
      final result = await service.parseJobUrl(url);
      
      expect(result.source, 'Other');
      expect(result.originalUrl, url);
    });

    test('detects countries correctly', () async {
      final scenarios = {
        'https://ae.linkedin.com/jobs': 'AE',
        'https://www.bayt.com/en/al-kuwait/jobs': 'KW', // kuwait -> KW
        'https://sa.indeed.com/jobs': 'SA',
        'https://www.monster.co.uk/job': 'UK',
        'https://qa.linkedin.com/job': 'QA',
      };

      for (final entry in scenarios.entries) {
        final result = await service.parseJobUrl(entry.key);
        // Debug print
        // print('Expected ${entry.value} for ${entry.key}, got ${result.country}');
        expect(result.country, entry.value, reason: 'Failed country for ${entry.key}');
      }
    });

    test('isValidJobUrl validates correctly', () {
      expect(service.isValidJobUrl('https://linkedin.com'), isTrue);
      expect(service.isValidJobUrl('http://indeed.com'), isTrue);
      expect(service.isValidJobUrl('not a url'), isFalse);
      expect(service.isValidJobUrl('ftp://example.com'), isFalse);
    });
  });
}
