import 'package:cloud_firestore/cloud_firestore.dart';

class NoteFields {
  static final List<String> values = [
    id,
    prioritise,
    title,
    content,
    createdTime,
    lastModifyTime,
  ];

  static const String id = '_id';
  static const String prioritise = 'prioritise';
  static const String title = 'title';
  static const String content = 'content';
  static const String createdTime = 'createdTime';
  static const String lastModifyTime = 'lastModifyTime';
}

class Note {
  final int? id;
  late bool prioritise;
  late String title;
  late String content;
  late DateTime createdTime;
  late DateTime lastModifyTime;

  changePrioritise() {
    prioritise = !prioritise;
  }

  changeTitle(String newTitle) {
    title = newTitle;
  }

  changeContent(String newContent) {
    content = newContent;
  }

  changeLastModifyTime() {
    lastModifyTime = DateTime.now();
  }

  Note({
    required this.id,
    required this.prioritise,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.lastModifyTime,
  });

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.content: content,
        NoteFields.prioritise: prioritise ? 0 : 1,
        NoteFields.createdTime: createdTime.toIso8601String(),
        NoteFields.lastModifyTime: lastModifyTime.toIso8601String(),
      };

  Note copy({
    int? id,
    bool? prioritise,
    String? title,
    String? content,
    DateTime? createdTime,
    DateTime? lastModifyTime,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        prioritise: prioritise ?? this.prioritise,
        createdTime: createdTime ?? this.createdTime,
        lastModifyTime: lastModifyTime ?? this.lastModifyTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        title: json[NoteFields.title] as String,
        content: json[NoteFields.content] as String,
        prioritise: json[NoteFields.prioritise] == 0,
        createdTime: DateTime.parse(json[NoteFields.createdTime] as String),
        lastModifyTime:
            DateTime.parse(json[NoteFields.lastModifyTime] as String),
      );

  factory Note.fromFirebase(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Note(
      id: data?[NoteFields.id],
      title: data?[NoteFields.title],
      content: data?[NoteFields.content],
      prioritise: data?[NoteFields.prioritise] == 0,
      createdTime: DateTime.parse(data?[NoteFields.createdTime] as String),
      lastModifyTime:
          DateTime.parse(data?[NoteFields.lastModifyTime] as String),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NoteFields.id: id,
      NoteFields.title: title,
      NoteFields.content: content,
      NoteFields.prioritise: prioritise ? 0 : 1,
      NoteFields.createdTime: createdTime.toIso8601String(),
      NoteFields.lastModifyTime: lastModifyTime.toIso8601String(),
    };
  }
}
