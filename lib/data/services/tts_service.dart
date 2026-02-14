import 'dart:io';
import 'dart:convert';
import 'package:devx_tts/presentation/settings/settings_controller.dart';
import 'package:devx_tts/presentation/widgets/text_entry/text_entry_controller.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/di.dart';

class TTSService {
  Process? _serverProcess;

  Future<void> startServer() async {
    final settings = locator<SettingsController>();
    final textEntry = locator<TextEntryController>();

    try {
      final baseDir = await getApplicationSupportDirectory();
      final exeName = Platform.isWindows ? 'run.exe' : 'run';
      final exePath = p.join(baseDir.path, exeName);

      // 1. Assets dan nusxalash
      final data = await rootBundle.load('assets/$exeName');
      await File(exePath).writeAsBytes(data.buffer.asUint8List(), flush: true);

      if (Platform.isMacOS) await Process.run('chmod', ['+x', exePath]);

      // 2. Jarayonni boshlash
      _serverProcess = await Process.start(exePath, [settings.value.port]);
      settings.updateServerStatus("loading");
      // 3. Loglarni tinglash
      _serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        print("data: $data");
        if (data.contains("Model tayyor")) {
          textEntry.setServerStatus(true);
          settings.updateServerStatus("loaded");
        }
      });

      _serverProcess!.stderr.transform(utf8.decoder).listen((err) {
        print("err: $err");
        if (err.toLowerCase().contains("error") || err.toLowerCase().contains("exception")) {
          settings.updateServerStatus("error");
        } else {
          textEntry.setServerStatus(true);
          settings.updateServerStatus("loaded");
        }
      });

    } catch (e) {
      settings.updateServerStatus("error");
    }
  }

  void stopServer() {
    _serverProcess?.kill();
    _serverProcess = null;
  }
}