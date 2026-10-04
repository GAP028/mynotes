import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/notes_service.dart';
import 'note_form_page.dart';

class NotesPage extends StatelessWidget {
  NotesPage({super.key});

  final _auth = AuthService();
  final _notesService = NotesService();

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: Text('« ${note.title} » sera définitivement supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _notesService.deleteNote(note.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer la note.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: _auth.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter une note',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NoteFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _notesService.watchNotes(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les notes. '
                  'Vérifiez votre connexion et les règles Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return const Center(child: Text("Aucune note pour l'instant."));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final note = notes[i];
              return Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteFormPage(note: note),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Supprimer',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, note),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
