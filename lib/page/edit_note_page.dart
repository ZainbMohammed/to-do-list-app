import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import '../widget/note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late bool isImportant;
  late int number;
  late String title;
  late String description;

  @override
  void initState() {
    super.initState();

    isImportant = widget.note?.isImportant ?? false;
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Column(
        // appBar: AppBar(
        //   actions: [buildButton()],
        // ),
        children: [
          Row(
            children: [
              buildButton(),
              Form(
                key: _formKey,
                child: NoteFormWidget(
                  isImportant: isImportant,
                  number: number,
                  title: title,
                  description: description,
                  onChangedImportant: (isImportant) =>
                      setState(() => this.isImportant = isImportant),
                  onChangedNumber: (number) =>
                      setState(() => this.number = number),
                  onChangedTitle: (title) => setState(() => this.title = title),
                  onChangedDescription: (description) =>
                      setState(() => this.description = description),
                ),
              ),
            ],
          )
        ],
      );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(0),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(.8),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    isFormValid ? Colors.white : Colors.grey.shade500,
              ),
              onPressed: addOrUpdateNote,
              child: const Text(
                'Add',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0),
              ),
            ),
          ],
        ));
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      isImportant: isImportant,
      number: number,
      title: title,
      description: description,
    );

    await NotesDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: title,
      isImportant: true,
      number: number,
      description: description,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.create(note);
  }
}
