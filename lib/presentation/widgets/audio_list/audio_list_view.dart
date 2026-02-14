import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../core/di.dart';
import '../../../data/models/audio_model.dart';
import 'audio_list_controller.dart';

// Ijro holatini kuzatish uchun global player (yoki DI ga qo'shish mumkin)
final AudioPlayer _audioPlayer = AudioPlayer();
String? _currentlyPlayingId;

class AudioListView extends StatelessWidget {
  const AudioListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = locator<AudioListController>();
    return ValueListenableBuilder<List<AudioModel>>(
      valueListenable: controller,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return const Center(child: Text("Hozircha audiolar yo'q"));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => _AudioItem(audio: list[index]),
        );
      },
    );
  }
}

class _AudioItem extends StatefulWidget {
  final AudioModel audio;
  const _AudioItem({required this.audio});

  @override
  State<_AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<_AudioItem> {
  bool get isPlaying => _currentlyPlayingId == widget.audio.id;

  @override
  Widget build(BuildContext context) {
    final controller = locator<AudioListController>();

    return ExpansionTile(
      leading: IconButton(
        icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: isPlaying ? Colors.orange : Colors.blue, size: 32),
        onPressed: _togglePlay,
      ),
      title: Text(widget.audio.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Davomiyligi: ${widget.audio.duration} • ${widget.audio.createdAt.toString().substring(0, 16)}"),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Matn: ${widget.audio.text}", style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
              Text("Generatsiya vaqti: ${widget.audio.genTime} soniya",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. To'xtatish tugmasi
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.black),
                    onPressed: isPlaying ? _stopPlay : null,
                  ),
                  // 2. Nomni o'zgartirish
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showRenameDialog(context, controller),
                  ),
                  // 3. Yuklab olish (Nusxalash)
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.green),
                    onPressed: () => _downloadFile(context),
                  ),
                  // 4. O'chirish
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, controller),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  // --- Tugmalar mantiqi ---

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() => _currentlyPlayingId = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(widget.audio.path));
      setState(() => _currentlyPlayingId = widget.audio.id);

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _currentlyPlayingId = null);
      });
    }
  }

  Future<void> _stopPlay() async {
    await _audioPlayer.stop();
    setState(() => _currentlyPlayingId = null);
  }

  void _showRenameDialog(BuildContext context, AudioListController controller) {
    final textController = TextEditingController(text: widget.audio.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nomni o'zgartirish"),
        content: TextField(controller: textController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Bekor qilish")),
          ElevatedButton(
            onPressed: () {
              controller.renameAudio(widget.audio, textController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Saqlash"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'Audioni saqlash',
        fileName: '${widget.audio.name}.wav',
      );
      if (result != null) {
        await File(widget.audio.path).copy(result);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fayl saqlandi!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xato: $e")));
    }
  }

  void _showDeleteConfirm(BuildContext context, AudioListController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text("Haqiqatdan ham ushbu audioni o'chirmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Yo'q")),
          TextButton(
            onPressed: () {
              controller.deleteAudio(widget.audio);
              Navigator.pop(ctx);
            },
            child: const Text("Ha, o'chirilsin", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}