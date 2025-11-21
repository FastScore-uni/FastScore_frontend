enum TranscriptionModel{
  basicPitch(
    displayName: 'Basic Pitch',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
  ),
  crepe(
      displayName: 'Crepe',
      description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris',
  ),
  omnizart(
    displayName: 'Omnizart',
    description: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum',
  );

  final String displayName;
  final String description;
  const TranscriptionModel({
    required this.displayName,
    required this.description,
  });
}