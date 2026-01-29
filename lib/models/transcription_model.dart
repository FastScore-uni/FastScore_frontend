enum TranscriptionModel{
  basicPitch(
    displayName: 'Basic Pitch',
    description: 'Szybkie działanie, obsługuje wiele lini melodycznych, nie zawsze jednak zwraca dokładne wyniki.',
    apiPath: '/convert-bp',
  ),
  crepe(
      displayName: 'Crepe',
      description: 'Obsługuje tylko jedną linię melodyczną, ma jednak wysoką dokładność. Generowanie nut może chwilę zająć.',
      apiPath: '/convert-crepe',
  ),
  crepePreproc(
    displayName: 'Crepe z preprocessingiem',
    description: 'Idealne do przetwarzania nagrań ze słabą jakością, lub zaszumieniem. Może zniekształcić zwykłe nagrania',
    apiPath: '/convert-crepe-preproc',
  );

  final String displayName;
  final String description;
  final String apiPath;
  const TranscriptionModel({
    required this.displayName,
    required this.description,
    required this.apiPath,
  });



  String url(String originUrl) => originUrl + apiPath;
   // String get url => 'https://audio-to-xml-417992603605.us-central1.run.app';

}
