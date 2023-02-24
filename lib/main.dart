import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/pages/NotesPage.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.black38,
    ),
    home: NotesPage(false),
  ));
}
