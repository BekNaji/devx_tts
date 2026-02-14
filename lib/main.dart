import 'package:devx_tts/presentation/main_app.dart';
import 'package:flutter/material.dart';
import 'core/di.dart';
import 'data/services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  locator<TTSService>().startServer();

  runApp(const UzbekTTSApp());
}

class UzbekTTSApp extends StatefulWidget {
  const UzbekTTSApp({super.key});

  @override
  State<UzbekTTSApp> createState() => _UzbekTTSAppState();
}

class _UzbekTTSAppState extends State<UzbekTTSApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Ilova butunlay yopilganda serverni o'chirish
    locator<TTSService>().stopServer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Agar foydalanuvchi ilovani butunlay yopsa (Terminate)
    if (state == AppLifecycleState.detached) {
      locator<TTSService>().stopServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: MainApp(), // Bu yerda faqat UI view chaqiriladi
    );
  }
}