// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/note.dart';

void initialiseFirebase() async {
  await Firebase.initializeApp();
}

class NotesFirebaseDatabase {
  final String NOTE_DOC_NAME = '_notes';
  static NotesFirebaseDatabase instance = NotesFirebaseDatabase._init();
  static CollectionReference<Map<String, dynamic>>? _firebaseStore;

  NotesFirebaseDatabase._init();

  Future<CollectionReference<Map<String, dynamic>>> get firebaseStore async {
    _firebaseStore ??= FirebaseFirestore.instance.collection(NOTE_DOC_NAME);
    return _firebaseStore!;
  }

  Future<List<Note>> readAllNotes() async {
    final firebaseFireStore = await instance.firebaseStore;
    var notes = firebaseFireStore
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

  Future<String?> findNoteId(Note note) async {
    final firebaseFireStore = await instance.firebaseStore;
    var querySnapshot = await firebaseFireStore.get();
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

  Future<void> deleteNote(Note note) async {
    String? id = await findNoteId(note);
    final firebaseFireStore = await instance.firebaseStore;
    await firebaseFireStore.doc(id).delete();
  }

  Future<void> updateNote(Note note) async {
    String? id = await findNoteId(note);
    final firebaseFireStore = await instance.firebaseStore;
    await firebaseFireStore.doc(id).set(note.toFirebase());
  }

  Future<void> createNote(Note note) async {
    final firebaseFireStore = await instance.firebaseStore;
    firebaseFireStore.withConverter(
      fromFirestore: Note.fromFirebase,
      toFirestore: (Note note, options) => note.toFirebase(),
    );
    await firebaseFireStore.doc().set(note.toFirebase());
  }
}