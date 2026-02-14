import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di.dart';

class SettingsState {
  final String port;
  final String namingFormat;
  final bool isLoading;
  final bool isLoaded;
  final bool isError;
  final String? serverMessage;

  SettingsState({
    required this.port,
    required this.namingFormat,
    this.isLoading = false,
    this.isLoaded = false,
    this.isError = false,
    this.serverMessage,
  });

  SettingsState copyWith({
    String? port,
    String? namingFormat,
    bool? isLoaded,
    bool? isLoading,
    bool? isError,
    String? serverMessage,
  }) {
    return SettingsState(
      port: port ?? this.port,
      namingFormat: namingFormat ?? this.namingFormat,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      serverMessage: serverMessage ?? this.serverMessage,
    );
  }
}

class SettingsController extends ValueNotifier<SettingsState> {
  final SharedPreferences _prefs = locator<SharedPreferences>();

  SettingsController()
    : super(
        SettingsState(
          port: locator<SharedPreferences>().getString('port') ?? "5005",
          namingFormat:
              locator<SharedPreferences>().getString('naming_format') ??
              "voice_timestamp",
        ),
      );

  Future<void> updatePort(String newPort) async {
    await _prefs.setString('port', newPort);
    value = value.copyWith(port: newPort);
  }

  Future<void> updateNamingFormat(String format) async {
    await _prefs.setString('naming_format', format);
    value = value.copyWith(namingFormat: format);
  }

  void updateServerStatus(String status) {
    String? message;
    if (status == 'loading') {
      message = "Yuklanmoqda";
    } else if (status == 'error') {
      message = "Serverni yuklashda xatolik yuz berdi, qayta urinib ko'ring";
    } else if (status == "loaded") {
      message = "Tayyor";
    }
    value = value.copyWith(
      isLoading: status == 'loading',
      isLoaded: status == 'loaded',
      isError: status == "error",
      serverMessage: message,
    );
  }
}
