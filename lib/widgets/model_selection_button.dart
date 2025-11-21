import 'package:flutter/material.dart';
import 'package:fastscore_frontend/models/transcription_model.dart';

typedef ModelSelectedCallback = void Function(TranscriptionModel selectedModel);

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
  TranscriptionModel? _selectedModel;

  void _showSelectionDialog() async {
      TranscriptionModel? newModel = await showDialog<TranscriptionModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wybierz model transkrypcji'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: TranscriptionModel.values.map((model) {
                return ListTile(
                  title: Text(model.displayName),
                  subtitle: Text(model.description),
                  onTap: () {
                    Navigator.pop(context, model);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (newModel != null) {
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
      label: Text(
        _selectedModel?.displayName ?? 'Wybierz model transkrypcji (domyślnie: Basic Pitch)',
      ),
    );
  }
}