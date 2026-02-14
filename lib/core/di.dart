import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/tts_service.dart';
import '../presentation/settings/settings_controller.dart';
import '../presentation/widgets/audio_list/audio_list_controller.dart';
import '../presentation/widgets/text_entry/text_entry_controller.dart';
final locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  // Servislar
  locator.registerLazySingleton(() => TTSService());

  // Controllerlar
  locator.registerLazySingleton(() => SettingsController());
  locator.registerLazySingleton(() => TextEntryController());
  locator.registerLazySingleton(() => AudioListController());
}