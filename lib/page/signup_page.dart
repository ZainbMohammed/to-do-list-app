// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   File _imageFile;
//   final picker = ImagePicker();

//   Future<void> _getImageFromGallery() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//         // Save image path to SQLite database
//         _saveImagePathToDatabase(_imageFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future<void> _deleteProfilePicture() async {
//     setState(() {
//       _imageFile = null;
//       // Remove image path from SQLite database
//       _removeImagePathFromDatabase();
//     });
//   }

//   Future<void> _saveImagePathToDatabase(String imagePath) async {
//     final database = await openDatabase(
//       join(await getDatabasesPath(), 'profile_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE profile(id INTEGER PRIMARY KEY, image_path TEXT)",
//         );
//       },
//       version: 1,
//     );
//     await database.insert(
//       'profile',
//       {'image_path': imagePath},
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> _removeImagePathFromDatabase() async {
//     final database = await openDatabase(
//       join(await getDatabasesPath(), 'profile_database.db'),
//       version: 1,
//     );
//     await database.delete('profile');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _imageFile == null
//                 ? Text('No profile picture selected')
//                 : Image.file(_imageFile),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _getImageFromGallery,
//               child: Text('Change Profile Picture'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _deleteProfilePicture,
//               child: Text('Delete Profile Picture'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: ProfilePage(),
//   ));
// }