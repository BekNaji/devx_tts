import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:devx_tts/core/di.dart';
import 'package:devx_tts/data/models/audio_model.dart';
import 'package:devx_tts/presentation/settings/settings_controller.dart';
import 'package:devx_tts/presentation/widgets/audio_list/audio_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// 1. Controller klassi
class TextEntryController extends ValueNotifier<TextEntryState> {
  TextEntryController() : super(TextEntryState());

  Timer? _progressTimer;

  void setServerStatus(bool ready) {
    value = value.copyWith(isServerReady: ready);
  }

  void updateLanguage(String lang) {
    value = value.copyWith(selectedLang: lang);
  }

  // --- QO'SHILDI: Sekundlarni 00:00 formatiga o'tkazish ---
  String _formatDuration(double totalSeconds) {
    if (totalSeconds.isNaN || totalSeconds.isInfinite) return "00:00";
    Duration duration = Duration(milliseconds: (totalSeconds * 1000).toInt());
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> generateTTS(String text) async {
    if (text.isEmpty || !value.isServerReady) return;

    final settings = locator<SettingsController>();
    final audioList = locator<AudioListController>();

    value = value.copyWith(isLoading: true, progress: 0.0, status: "Tayyorlanmoqda...");
    final stopwatch = Stopwatch()..start();

    int estimatedSecs = (text.length * 0.005).ceil() + 1;
    _startProgressTimer(estimatedSecs < 2 ? 2 : estimatedSecs);

    try {
      final baseDir = await getApplicationSupportDirectory();
      final audioDir = Directory(p.join(baseDir.path, 'audios'));
      if (!await audioDir.exists()) await audioDir.create(recursive: true);

      String fileName = _generateFileName(text, settings.value.namingFormat);
      String outputPath = p.join(audioDir.path, "$fileName.wav");

      final response = await http.post(
        Uri.parse('http://127.0.0.1:${settings.value.port}/tts'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "lang": value.selectedLang,
          "file": outputPath,
          "model": value.selectedLang.toLowerCase()
        }),
      ).timeout(const Duration(minutes: 5));

      stopwatch.stop();

      if (response.statusCode == 200) {
        _progressTimer?.cancel();

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic rawDuration = responseData['duration'] ?? 0.0;
        final double durationInSeconds = double.tryParse(rawDuration.toString()) ?? 0.0;

        final newAudio = AudioModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: outputPath,
          name: fileName,
          text: text,
          duration: _formatDuration(durationInSeconds),
          genTime: stopwatch.elapsedMilliseconds / 1000,
          createdAt: DateTime.now(),
        );

        audioList.addAudio(newAudio);

        value = value.copyWith(
            isLoading: false,
            progress: 1.0,
            status: "Muvaffaqiyatli! (${newAudio.genTime}s)"
        );
      } else {
        throw Exception("Server xatosi");
      }
    } catch (e,line) {
      print(e.toString());
      print(line);
      _progressTimer?.cancel();
      value = value.copyWith(isLoading: false, status: "Xato: $e", progress: 0.0);
    }
  }

  String _generateFileName(String text, String format) {
    if (format == "text_basis") {
      String cleanText = text.replaceAll(RegExp(r'[^\w\s]+'), '');
      List<String> words = cleanText.split(' ');
      return "${words.take(3).join('_')}_${DateTime.now().millisecondsSinceEpoch}";
    }
    return "voice_${DateTime.now().millisecondsSinceEpoch}";
  }

  void _startProgressTimer(int seconds) {
    _progressTimer?.cancel();
    int ticks = 0;
    int maxTicks = seconds * 10;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      ticks++;
      double currentProgress = (ticks / maxTicks).clamp(0.0, 0.98);
      value = value.copyWith(progress: currentProgress, status: "Generatsiya qilinmoqda...");
      if (ticks >= maxTicks) timer.cancel();
    });
  }
}

// 2. State klassi o'zgarishsiz qoladi
class TextEntryState {
  final bool isLoading;
  final bool isServerReady;
  final double progress;
  final String status;
  final String selectedLang;

  TextEntryState({
    this.isLoading = false,
    this.isServerReady = false,
    this.progress = 0.0,
    this.status = "Tayyor",
    this.selectedLang = "uz",
  });

  TextEntryState copyWith({
    bool? isLoading,
    bool? isServerReady,
    double? progress,
    String? status,
    String? selectedLang,
  }) {
    return TextEntryState(
      isLoading: isLoading ?? this.isLoading,
      isServerReady: isServerReady ?? this.isServerReady,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      selectedLang: selectedLang ?? this.selectedLang,
    );
  }
}