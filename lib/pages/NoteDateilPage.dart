import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/pages/NotesPage.dart';

import '../model/Note.dart';
import '../service/NotesDatabase.dart';
import '../service/NotesFirebaseDatabase.dart';

class NoteDetailPage extends StatefulWidget {
  Note? note;
  String? noteId;
  bool page;

  NoteDetailPage(this.note, this.noteId, this.page, {super.key});

  @override
  State<StatefulWidget> createState() =>
      _NoteDetailPageState(note, noteId, page);
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  Note? note;
  String? noteId;
  bool page;
  final docNotes = FirebaseFirestore.instance.collection("_notes").doc();

  _NoteDetailPageState(this.note, this.noteId, this.page) {
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;
      noteId = noteId;
    }
    page = page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.white12,
              title: const Text('Add Note'),
              actions: <Widget>[
                IconButton(
                  color: Colors.amberAccent,
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    addNote();
                  },
                ),
              ],
            ),
            buildTextFields(1, 'Title', titleController),
            Flexible(child: buildTextFields(50, 'Note...', contentController)),
          ],
        ),
      ),
    );
  }

  Widget buildTextFields(
      int maxLines, String hintText, TextEditingController controller) {
    return Card(
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amberAccent),
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesPage(page),
        ));
  }

  void addNote() async {
    if (titleController.text.isNotEmpty) {
      if (note == null) {
        note = Note(
          id: null,
          title: titleController.text,
          content: contentController.text,
          prioritise: false,
          createdTime: DateTime.now(),
          lastModifyTime: DateTime.now(),
        );
      } else {
        note!.changeTitle(titleController.text);
        note!.changeContent(contentController.text);
        note!.changeLastModifyTime();
      }

      if (note!.id != null) {
        await NoteDatabase.instance.updateNote(note!);
        await NotesFirebaseDatabase.updateNote(note!);
      } else {
        note = await NoteDatabase.instance.createNote(note!);
        await NotesFirebaseDatabase.createNote(note!);
      }
    }
    moveToLastScreen();
  }
}