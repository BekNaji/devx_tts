class AudioModel {
  final String id;
  String path;
  String name;
  final String text;
  final String duration;
  final double genTime;
  final DateTime createdAt;

  AudioModel({
    required this.id, required this.path, required this.name,
    required this.text, required this.duration, required this.genTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'path': path, 'name': name, 'text': text,
    'duration': duration, 'genTime': genTime, 'createdAt': createdAt.toIso8601String(),
  };

  factory AudioModel.fromMap(Map<String, dynamic> map) => AudioModel(
    id: map['id'], path: map['path'], name: map['name'], text: map['text'],
    duration: map['duration'], genTime: map['genTime'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}