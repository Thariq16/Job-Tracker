void main() {
  final uri = Uri.parse('https://ae.linkedin.com/jobs');
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();
  
  print('Host: $host');
  print('Path: $path');

  final countryPatterns = {
    'ae': ['ae', 'uae', 'dubai', 'abudhabi'],
    'sa': ['sa', 'saudi', 'ksa'],
  };
  
  for (final entry in countryPatterns.entries) {
    for (final pattern in entry.value) {
      bool condition1 = host.contains('.$pattern');
      bool condition2 = host.endsWith('.$pattern');
      bool condition3 = host.startsWith('$pattern.');
      bool condition4 = path.contains('/$pattern/');
      bool condition5 = path.startsWith('/$pattern/');
      
      print('Pattern: $pattern');
      print('starts with $pattern.: $condition3');
      
      if (condition1 || condition2 || condition3 || condition4 || condition5) {
        print('MATCHED: ${entry.key.toUpperCase()}');
        return;
      }
    }
  }
  print('NO MATCH');
}
