import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;
import '../../enums/menu_action.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';
import '../../services/cloud/cloud_note.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import 'notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Notes'), actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
          ),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout) {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                }
            }
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text('Logout'))
            ];
          })
        ]),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }

              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

// Future<bool> showLogOutDialog(BuildContext context) {
//   return showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Sign out'),
//         content: const Text('Are you sure you want to sign out?'),
//         actions: [
//           TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: const Text('Cancel')),
//           TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('Log out')),
//         ],
//       );
//     },
//   ).then((value) => value ?? false);
// }
