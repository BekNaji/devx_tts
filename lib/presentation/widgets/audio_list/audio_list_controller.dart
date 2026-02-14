import 'dart:convert';

import 'package:devx_tts/core/di.dart';
import 'package:devx_tts/data/models/audio_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../../../core/di.dart';
import '../../../data/models/audio_model.dart';

class AudioListController extends ValueNotifier<List<AudioModel>> {
  // SharedPreferences ni DI orqali olamiz
  final SharedPreferences _prefs = locator<SharedPreferences>();

  AudioListController() : super([]) {
    // Ilova ishga tushganda eski ma'lumotlarni yuklaymiz
    _loadFromStorage();
  }

  // 1. Yangi audio qo'shish (TextEntryController buni chaqiradi)
  void addAudio(AudioModel audio) {
    value = [audio, ...value];
    _saveToStorage();
  }

  // 2. Audioni o'chirish
  Future<void> deleteAudio(AudioModel audio) async {
    try {
      final file = File(audio.path);
      if (await file.exists()) {
        await file.delete();
      }

      // Ro'yxatdan olib tashlash
      value = value.where((item) => item.id != audio.id).toList();
      _saveToStorage();
    } catch (e) {
      debugPrint("O'chirishda xato: $e");
    }
  }

  // 3. Audio nomini o'zgartirish (Rename)
  Future<void> renameAudio(AudioModel audio, String newName) async {
    try {
      final file = File(audio.path);
      final String directory = p.dirname(audio.path);
      final String newPath = p.join(directory, "$newName.wav");

      if (await file.exists()) {
        await file.rename(newPath);

        // Modelni yangilash
        final index = value.indexWhere((item) => item.id == audio.id);
        if (index != -1) {
          value[index].name = newName;
          value[index].path = newPath;
          notifyListeners(); // UI ni yangilash
          _saveToStorage();
        }
      }
    } catch (e) {
      debugPrint("Nomni o'zgartirishda xato: $e");
    }
  }

  // 4. Ma'lumotlarni saqlash (Private)
  void _saveToStorage() {
    final List<String> encodedList = value.map((audio) => jsonEncode(audio.toMap())).toList();
    _prefs.setStringList('audio_history', encodedList);
  }

  // 5. Ma'lumotlarni yuklash (Private)
  void _loadFromStorage() {
    final List<String>? data = _prefs.getStringList('audio_history');
    if (data != null) {
      value = data.map((item) => AudioModel.fromMap(jsonDecode(item))).toList();
    }
  }
}