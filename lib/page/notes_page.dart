import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_tasks_app/page/login.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
// import '../model/users2.dart'; // Import your User model
import '../page/edit_note_page.dart';
import '../page/note_detail_page.dart';
// import '../page/login.dart'; // Import your LoginPage
import '../widget/note_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  List<Note> _foundToDo = [];

  bool isLoading = false;
  bool isLoggedIn = false; // New variable to track login status
  // bool isLoggedIn = false; // Declare isLoggedIn before using it

  @override
  void initState() {
    super.initState();

    // Check if user is logged in on app start
    checkLoginStatus();
  }

  Future checkLoginStatus() async {
    final loggedIn =
        await isUserLoggedIn(); // Assuming you have a method to check login status
    setState(() => this.isLoggedIn = loggedIn);

    if (loggedIn) {
      refreshNotes(); // Load notes if user is logged in
    } else {
      navigateToLogin(); // Navigate to login screen if user is not logged in
    }
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  void navigateToLogin() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) => _runFilter(value),
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Search notes...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  fillColor: Colors.grey.shade800,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : notes.isEmpty
                        ? const Text(
                            'No Notes',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          )
                        : buildNotes(),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.add,
              size: 30,
              weight: 10.0,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const AddEditNotePage()),
              );

              refreshNotes();
            },
          ),
        ),
      );

//   Widget buildNotes() {
//     if (notes == null) {
//     return CircularProgressIndicator(); // Show a loading indicator while notes are being fetched
//   } else if (notes.isEmpty) {
//     return Text(
//       'No Notes',
//       style: TextStyle(color: Colors.white, fontSize: 24),
//     );
//   } else{
//     return StaggeredGrid.count(
//         crossAxisCount: 2,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 5,
//         children: List.generate(
//           notes.length,
//           (index) {
//             final note = notes[index];

//             return StaggeredGridTile.fit(
//               crossAxisCellCount: 1,
//               child: GestureDetector(
//                 onTap: () async {
//                   await Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => NoteDetailPage(noteId: note.id!),
//                   ));

//                   refreshNotes();
//                 },
//                 child: NoteCardWidget(note: note, index: index),
//               ),
//             );
//           },
//         ),
//     );
//   }
// }
Widget buildNotes() {
  return FutureBuilder<List<Note>>(
    future: NotesDatabase.instance.readAllNotes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error loading notes'));
      } else if (snapshot.hasData) {
        notes = snapshot.data!;
        return StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 5,
          children: List.generate(
            notes.length,
            (index) {
              final note = notes[index];

              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NoteDetailPage(noteId: note.id!),
                    ));

                    refreshNotes();
                  },
                  child: NoteCardWidget(note: note, index: index),
                ),
              );
            },
          ),
        );
      } else {
        return Center(child: Text('No Notes'));
      }
    },
  );
}

   
  void _runFilter(String enteredKeyword) {
    List<Note> results = [];
    if (enteredKeyword.isEmpty) {
      results = notes;
    } else {
      results = notes
          .where((note) =>
              note.title.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              note.description
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }
}
