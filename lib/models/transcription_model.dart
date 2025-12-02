enum TranscriptionModel{
  basicPitch(
    displayName: 'Basic Pitch',
    description: 'Szybkie działanie, obsługuje wiele lini melodycznych, nie zawsze jednak zwraca dokładne wyniki.',
    apiPath: '/convert_bp',
  ),
  crepe(
      displayName: 'Crepe',
      description: 'Obsługuje tylko jedną linię melodyczną, ma jednak wysoką dokładność. Generowanie nut może chwilę zająć.',
      apiPath: '/convert_crepe',
  ),
  melodyExtraction(
    displayName: 'Melody Extraction',
    description: 'Wyciąga z utworu polifonicznego pojedynczą linię melodyczną.',
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

  //String get url => 'http://127.0.0.1:8000$apiPath';
  String get url => 'https://audio-to-xml-417992603605.us-central1.run.app';

}