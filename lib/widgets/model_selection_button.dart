import 'package:flutter/material.dart';

typedef ModelSelectedCallback = void Function(String selectedModel);

class ModelSelectionButton extends StatefulWidget {
  final ModelSelectedCallback? onModelSelected;
  const ModelSelectionButton({
    super.key,
    required this.onModelSelected,
  });


  @override
  State<ModelSelectionButton> createState() => _ModelSelectionButtonState();
}

class _ModelSelectionButtonState extends State<ModelSelectionButton> {
  String _selectedModel = 'Wybierz model transkrypcji';

  final Map<String, String> _transcriptionModels = {
    'Basic Pitch': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Omnizart': 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
    'Crepe': 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.',
  };

  void _showSelectionDialog() async {
    final String? newModel = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wybierz model transkrypcji'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _transcriptionModels.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                  onTap: () {
                    Navigator.pop(context, entry.key);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (newModel != null && newModel.isNotEmpty) {
      setState(() {
        _selectedModel = newModel;
      });
      if (widget.onModelSelected != null) {
        widget.onModelSelected!(newModel);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: _showSelectionDialog,
      icon: const Icon(Icons.keyboard_arrow_down),
      label: Text(_selectedModel),
    );
  }
}