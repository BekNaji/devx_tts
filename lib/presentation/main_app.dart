import 'package:devx_tts/presentation/settings/settings_view.dart';
import 'package:devx_tts/presentation/widgets/audio_list/audio_list_view.dart';
import 'package:devx_tts/presentation/widgets/text_entry/text_entry_view.dart';
import 'package:flutter/material.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Yuqori qism (AppBar)
      appBar: AppBar(
        title: const Text(
          "DEVX UZ - TTS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsView()),
              );
            },
          ),
        ],
      ),

      // 2. Asosiy tana (Body)
      body: SafeArea(
        child: Column(
          children: [
            TextEntryView(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    "Ovozlar tarixi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Audiolar ro'yxati (Expanded qilingan, chunki u scroll bo'lishi kerak)
            Expanded(
              child: AudioListView(),
            ),
          ],
        ),
      ),

      // Ixtiyoriy: Server holatini bildiruvchi kichik indicator
      bottomNavigationBar: _buildBottomStatusBar(),
    );
  }

  // Server holatini ko'rsatuvchi pastki panel
  Widget _buildBottomStatusBar() {
    // Bu yerda SettingsController dagi server holatini ko'rsatish mumkin
    return Container(
      height: 25,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Local Server API: 127.0.0.1",
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}