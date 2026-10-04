import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/notes_service.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;

  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final _notesService = NotesService();
  final _auth = AuthService();

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        await _notesService.updateNote(
          id: widget.note!.id,
          title: _titleCtrl.text,
          content: _contentCtrl.text,
        );
      } else {
        await _notesService.addNote(
          userId: user.uid,
          title: _titleCtrl.text,
          content: _contentCtrl.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error = "L'enregistrement a échoué. Réessayez.");
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label est obligatoire';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la note' : 'Nouvelle note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _required(v, 'Le titre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentCtrl,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _required(v, 'Le contenu'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Enregistrer' : 'Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
