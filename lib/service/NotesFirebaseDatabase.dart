// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/Note.dart';

void initialiseFirebase() async {
  await Firebase.initializeApp();
}

class NotesFirebaseDatabase {
  final String NOTE_DOC_NAME = '_notes';

  static Future<List<Note>> readAllNotes() async {
    var notes = FirebaseFirestore.instance
        .collection('_notes')
        .orderBy(NoteFields.prioritise)
        .orderBy(NoteFields.lastModifyTime, descending: true);
    var querySnapshot = await notes.get();
    var docs = querySnapshot.docs;
    List<Note> notesList = [];

    for (var _querySnapshot in docs) {
      notesList.add(Note.fromFirebase(_querySnapshot, null));
    }
    return notesList;
  }

  static Future<Map<String, Note>> readAllNotesMap() async {
    var notes = FirebaseFirestore.instance.collection('_notes');
    var querySnapshot = await notes.get();
    var docs = querySnapshot.docs;
    Map<String, Note> notesList = {};

    for (var _querySnapshot in docs) {
      var id = _querySnapshot.id;
      var note = Note.fromFirebase(_querySnapshot, null);
      notesList.putIfAbsent(id, () => note);
    }
    return notesList;
  }

  static Future<String?> findNoteId(Note note) async {
    var notes = FirebaseFirestore.instance.collection('_notes');
    var querySnapshot = await notes.get();
    var docs = querySnapshot.docs;

    for (var _querySnapshot in docs) {
      var id = _querySnapshot.id;
      var _note = Note.fromFirebase(_querySnapshot, null);
      if (_note.id == note.id) {
        return id;
      }
    }
    return null;
  }

  static Future<void> deleteNote(Note note) async {
    String? id = await NotesFirebaseDatabase.findNoteId(note);

    await FirebaseFirestore.instance.collection("_notes").doc(id).delete();
  }

  static Future<void> updateNote(Note note) async {
    String? id = await NotesFirebaseDatabase.findNoteId(note);

    await FirebaseFirestore.instance
        .collection("_notes")
        .doc(id)
        .set(note.toFirebase());
  }

  static Future<void> createNote(Note note) async {
    FirebaseFirestore.instance
        .collection('_notes')
        .withConverter(
          fromFirestore: Note.fromFirebase,
          toFirestore: (Note note, options) => note.toFirebase(),
        )
        .doc("NA");
    await FirebaseFirestore.instance
        .collection('_notes')
        .doc()
        .set(note.toFirebase());
  }
}