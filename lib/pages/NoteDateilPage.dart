import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/Note.dart';
import '../service/NotesDatabase.dart';

class NoteDetailPage extends StatefulWidget {
  Note? note;

  NoteDetailPage(this.note, {super.key});

  @override
  State<StatefulWidget> createState() => _NoteDetailPageState(this.note);
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  Note? note;

  _NoteDetailPageState(this.note) {
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;
    }
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
                  onPressed: () {
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
              //borderRadius: BorderRadius.circular(15),
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void addNote() async {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
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
      } else {
        await NoteDatabase.instance.createNote(note!);
      }
    }
    moveToLastScreen();
  }
}
