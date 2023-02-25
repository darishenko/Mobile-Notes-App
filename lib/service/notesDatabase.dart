import 'dart:async';

import 'package:notes_app/model/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabase {
  final String databaseName = 'notes';
  static NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    _database ??= await _initDB('$databaseName.db');
    return _database!;
  }

  Future _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $databaseName(
    ${NoteFields.id} $idType,
    ${NoteFields.prioritise} $boolType,
    ${NoteFields.title} $textType,
    ${NoteFields.content} $textType,
    ${NoteFields.createdTime} $textType,
    ${NoteFields.lastModifyTime} $textType
    );
    ''');
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert(databaseName, note.toJson());
    return note.copy(id: id);
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final result = await db.query(databaseName,
        columns: NoteFields.values,
        where: '${NoteFields.id} = ?',
        whereArgs: [id]);

    if (result.isNotEmpty) {
      return Note.fromJson(result.first);
    } else {
      throw Exception('ID $id  is not found');
    }
  }

  Future<List<Note>> readAllNote() async {
    final db = await instance.database;
    const orderBy =
        '${NoteFields.prioritise} ASC, ${NoteFields.lastModifyTime} DESC';
    final result = await db.query(databaseName, orderBy: orderBy);
    List<Note> notesList =
        result.isNotEmpty ? result.map((e) => Note.fromJson(e)).toList() : [];
    return notesList;
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      databaseName,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> searchNote(String searchString) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM $databaseName WHERE title LIKE "%$searchString%" '
        'OR content LIKE "%$searchString%" ORDER BY "${NoteFields.lastModifyTime}"');

    List<Note> notesList =
        result.isNotEmpty ? result.map((e) => Note.fromJson(e)).toList() : [];
    return notesList;
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;

    return db
        .delete(databaseName, where: '${NoteFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
