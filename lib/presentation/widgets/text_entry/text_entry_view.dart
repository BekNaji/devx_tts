import 'package:devx_tts/core/di.dart';
import 'package:devx_tts/presentation/settings/settings_controller.dart';
import 'package:devx_tts/presentation/widgets/text_entry/text_entry_controller.dart';
import 'package:flutter/material.dart';

class TextEntryView extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  Map<String, String> lang = {
    "uz": "O'zbek tili",
    "ru": "Rus tili",
    "en": "Ingiliz tili",
    // "tr": "Turk tili",
  };

  @override
  Widget build(BuildContext context) {
    final controller = locator<TextEntryController>();
    return ValueListenableBuilder<TextEntryState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (state.isLoading)
                  LinearProgressIndicator(value: state.progress),
                TextField(controller: _textController, maxLines: 7),
                SizedBox(height: 10),
                Row(
                  children: [
                    ValueListenableBuilder<SettingsState>(
                      valueListenable: locator<SettingsController>(),
                      builder: (context, settingsState, _) {
                        return Text(settingsState.serverMessage ?? "");
                      },
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: lang.keys.map((String name) {
                              final bool isSelected = state.selectedLang == name;
                              return ChoiceChip(
                                label: Text(name, style: TextStyle(fontSize: 12)),
                                selected: isSelected,
                                selectedColor: Colors.blue.withOpacity(0.2),
                                onSelected: (bool selected) {
                                  if (selected) {
                                    controller.updateLanguage(name);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: state.isServerReady
                                ? () =>
                                controller.generateTTS(_textController.text)
                                : null,
                            child: Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
