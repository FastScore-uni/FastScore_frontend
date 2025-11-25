enum TranscriptionModel{
  basicPitch(
    displayName: 'Basic Pitch',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    apiPath: '/convert_bp',
  ),
  crepe(
      displayName: 'Crepe',
      description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris',
      apiPath: '/convert_crepe',
  ),
  melodyExtraction(
    displayName: 'Melody Extraction',
    description: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum',
    apiPath: '/convert_melody_ext',
  );

  final String displayName;
  final String description;
  final String apiPath;
  const TranscriptionModel({
    required this.displayName,
    required this.description,
    required this.apiPath,
  });

  String get url => 'http://127.0.0.1:8000$apiPath';
}