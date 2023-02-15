import 'package:notes_app/pages/NoteDateilPage.dart';
import 'package:notes_app/service/NotesDatabase.dart';
import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/SlidableAction.dart';

import '../model/Note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController searchString = TextEditingController();

  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    NoteDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    searchString.text.isNotEmpty
        ? notes = await NoteDatabase.instance.searchNote(searchString.text)
        : notes = await NoteDatabase.instance.readAllNote();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white30,
        appBar: AppBar(
          backgroundColor: Colors.white30,
          title: /*const Text('Notes'),*/
          Container(
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
                    // ignore: unrelated_type_equality_checks
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
                  prefixIcon:  const Icon(
                      Icons.search,
                    ),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.amberAccent,
                )
              : notes.isEmpty
                  ? const Text(
                      'No notes',
                      style: TextStyle(
                        color: Colors.amberAccent,
                      ),
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final item = notes[index];
                        return Slidable(
                          key: Key(item.title),
                          dismissal: SlidableDismissal(
                            child: const SlidableDrawerDismissal(),
                            onDismissed: (type) {
                              final action = type == SlideActionType.primary
                                  ? SlidableAction.favorite
                                  : SlidableAction.delete;

                              onDismissed(index, action);
                            },
                          ),
                          actionExtentRatio: 0.35,
                          actionPane: const SlidableDrawerActionPane(),
                          actions: <Widget>[
                            IconSlideAction(
                              color: Colors.pinkAccent,
                              icon: Icons.favorite,
                              onTap: () =>
                                  onDismissed(index, SlidableAction.favorite),
                            ),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              color: Colors.amberAccent,
                              icon: Icons.delete,
                              foregroundColor: Colors.white,
                              onTap: () {
                                return onDismissed(
                                    index, SlidableAction.delete);
                              },
                            ),
                          ],
                          child: buildNote(item),
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
                  builder: (context) => NoteDetailPage(null),
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
                  title: Text(note.title),
                  textColor: Colors.white,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note),
                        ));
                    refreshNotes();
                  },
                ),
              ),
            ],
          ),
        ),
      );

  void onDismissed(int index, SlidableAction action) {
    final item = notes[index];
    setState(() => notes.removeAt(index));

    switch (action) {
      case SlidableAction.delete:
        {
          NoteDatabase.instance.deleteNote(item.id!);
          showSnackBar(context, "${item.title} has been deleted.");
          break;
        }

      case SlidableAction.favorite:
        {
          item.changePrioritise();
          NoteDatabase.instance.updateNote(item);

          item.prioritise
          ? showSnackBar(context, "${item.title} has been added to favorites.")
          : showSnackBar(context, "${item.title} has been deleted from favorites.");

          break;
        }
    }
    refreshNotes();
  }

  showSnackBar(BuildContext context, text) {
    if (text is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
      ));
    } else if (text is Widget) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
    }
  }
}