// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:intl/intl.dart';
import 'package:notes_app/view/noteDetailPage.dart';
import 'package:notes_app/service/notesDatabase.dart';
import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/slidableAction.dart';

import '../model/note.dart';
import '../service/notesFirebaseDatabase.dart';
import '../service/internetConnection.dart';

class NotesPage extends StatefulWidget {
  bool page;

  NotesPage(this.page, {super.key});

  @override
  _NotesPageState createState() => _NotesPageState(this.page);
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController searchString = TextEditingController();

  bool isFirebaseNotes = false;
  late List<Note> currentNotes;
  bool isLoading = false;

  _NotesPageState(this.isFirebaseNotes) {
    isFirebaseNotes = isFirebaseNotes;
  }

  @override
  void initState() {
    super.initState();
    refreshNotes();
    initialiseFirebase();
  }

  @override
  void dispose() {
    NoteDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    currentNotes = [];
    searchString.text.isNotEmpty
        ? currentNotes =
            await NoteDatabase.instance.searchNote(searchString.text)
        : isFirebaseNotes
            ? currentNotes = await NotesFirebaseDatabase.instance.readAllNotes()
            : currentNotes = await NoteDatabase.instance.readAllNote();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white30,
        appBar: AppBar(
          backgroundColor: isFirebaseNotes ? Colors.white30 : Colors.pinkAccent,
          centerTitle: true,
          title: Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: TextField(
                controller: searchString,
                onChanged: (value) {
                  setState(() {
                    searchString == value;
                    refreshNotes();
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.clear,
                    ),
                    onPressed: () {
                      searchString.text = '';
                      refreshNotes();
                    },
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                hasInternetConnection().then((value) {
                  if (value) {
                    isFirebaseNotes = !isFirebaseNotes;
                  } else {
                    if (isFirebaseNotes) isFirebaseNotes = !isFirebaseNotes;
                    showSnackBar(context, "NO\tINTERNET\tCONNECTION!");
                  }
                });
                refreshNotes();
              },
              icon: const Icon(
                Icons.cloud,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Center(
          child: checkNotesState()
              ? notesStateWidget()
              : ListView.builder(
                  itemCount: currentNotes.length,
                  itemBuilder: (context, index) {
                    final note = currentNotes[index];
                    return Slidable(
                      key: Key(note.title),
                      dismissal: SlidableDismissal(
                        child: const SlidableDrawerDismissal(),
                        onDismissed: (type) {
                          final action = type == SlideActionType.primary
                              ? SlidableAction.favorite
                              : SlidableAction.delete;
                          onDismissed(note, action);
                        },
                      ),
                      actionExtentRatio: 0.45,
                      actionPane: const SlidableDrawerActionPane(),
                      actions: <Widget>[
                        IconSlideAction(
                          color: Colors.pinkAccent,
                          icon: Icons.favorite,
                          onTap: () {
                            onDismissed(note, SlidableAction.favorite);
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          color: Colors.amberAccent,
                          icon: Icons.delete,
                          foregroundColor: Colors.white,
                          onTap: () {
                            onDismissed(note, SlidableAction.delete);
                          },
                        ),
                      ],
                      child: buildNote(note),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black54,
          child: const Icon(
            Icons.add_outlined,
            color: Colors.amberAccent,
            size: 50.0,
          ),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NoteDetailPage(null, null, isFirebaseNotes),
                ));
            refreshNotes();
          },
        ),
      );

  Widget buildNote(Note note) => Builder(
        builder: (context) => Card(
          color: Colors.white30,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Icon(
                  note.prioritise ? Icons.favorite : null,
                  color: Colors.pinkAccent,
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    note.title,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                    ),
                  ),
                  textColor: Colors.white,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NoteDetailPage(note, ' ', isFirebaseNotes),
                        ));
                    refreshNotes();
                  },
                  subtitle: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        note.content,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '\n${DateFormat('yyyy-MM-dd – kk:mm').format(note.lastModifyTime)}',
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );

  void onDismissed(Note note, SlidableAction action) async {
    setState(() => currentNotes.remove(note));

    switch (action) {
      case SlidableAction.delete:
        {
          deleteNoteDialog(note);
          break;
        }
      case SlidableAction.favorite:
        {
          note.changePrioritise();
          await NoteDatabase.instance.updateNote(note);
          await NotesFirebaseDatabase.instance.updateNote(note);
          note.prioritise
              ? showSnackBar(
                  context, "${note.title} has been added to favorites.")
              : showSnackBar(
                  context, "${note.title} has been deleted from favorites.");
          break;
        }
    }
    refreshNotes();
  }

  void showSnackBar(BuildContext context, text) {
    if (text is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
      ));
    } else if (text is Widget) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
    }
  }

  Widget? notesStateWidget() {
    if (isLoading) {
      return const CircularProgressIndicator(
        color: Colors.amberAccent,
      );
    }

    if (currentNotes.isEmpty) {
      return const Text(
        'No notes',
        style: TextStyle(
          color: Colors.amberAccent,
        ),
      );
    }

    return null;
  }

  bool checkNotesState() {
    if (isFirebaseNotes) {
      hasInternetConnection().then((result) {
        if (!result) return true;
      });
    }
    if (isLoading || currentNotes.isEmpty) return true;

    return false;
  }

  Future<void> deleteNoteDialog(Note note) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white30,
          title: const Text('Delete note'),
          titleTextStyle: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to delete "${note.title}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () async {
                await deleteNote(note);
                showSnackBar(context, "${note.title} has been deleted.");
                Navigator.of(context).pop();
                refreshNotes();
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  deleteNote(Note note) async {
    await NoteDatabase.instance.deleteNote(note.id!);
    await NotesFirebaseDatabase.instance.deleteNote(note);
  }
}