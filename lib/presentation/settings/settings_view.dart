import 'package:flutter/material.dart';
import '../../core/di.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = locator<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Sozlamalar")),
      body: ValueListenableBuilder<SettingsState>(
        valueListenable: controller,
        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle("Tarmoq sozlamalari"),
              ListTile(
                leading: const Icon(Icons.router),
                title: const Text("Server porti"),
                subtitle: Text("Hozirgi: ${state.port}"),
                trailing: const Icon(Icons.edit),
                onTap: () => _showPortDialog(context, controller, state.port),
              ),
              const Divider(),
              _buildSectionTitle("Fayl sozlamalari"),
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline),
                title: const Text("Fayl nomlash formati"),
                subtitle: Text(
                  state.namingFormat == "voice_timestamp"
                      ? "voice_1739545.wav"
                      : "Matnning birinchi so'zlari.wav",
                ),
                onTap: () =>
                    _showNamingDialog(context, controller, state.namingFormat),
              ),
              const Divider(),
              _buildSectionTitle("Tizim statusi"),
              Builder(
                builder: (context) {
                  Color color = Colors.red;
                  String text = "No'malum";
                  if(state.isLoading){
                    color = Colors.yellow;
                  }
                  if(state.isLoaded && !state.isError){
                    color = Colors.green;
                  }
                  if(state.isError){
                    text = "Serverni ishga tushirishda xatolik yuz berdi";
                  }
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: color,
                    ),
                    title: const Text("Python Server holati"),
                    subtitle: Text(state.serverMessage ?? ""),
                  );
                }
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  void _showPortDialog(
    BuildContext context,
    SettingsController controller,
    String currentPort,
  ) {
    final textController = TextEditingController(text: currentPort);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Portni o'zgartirish"),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Masalan: 8080"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updatePort(textController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Saqlash"),
          ),
        ],
      ),
    );
  }

  void _showNamingDialog(
    BuildContext context,
    SettingsController controller,
    String current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Vaqt belgisi (voice_123.wav)"),
            leading: Radio(
              value: "voice_timestamp",
              groupValue: current,
              onChanged: (v) {
                controller.updateNamingFormat(v.toString());
                Navigator.pop(ctx);
              },
            ),
          ),
          ListTile(
            title: const Text("Matn asosi (salom_dunyo.wav)"),
            leading: Radio(
              value: "text_basis",
              groupValue: current,
              onChanged: (v) {
                controller.updateNamingFormat(v.toString());
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }
}
