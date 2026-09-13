import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _contentController =
      TextEditingController();

  List<String> _notes = [];

  bool get _isAndroid => Platform.isAndroid;

  bool get _isGlass {
    final theme = Theme.of(context);

    return theme.cardTheme.shape
            is RoundedRectangleBorder &&
        (theme.brightness == Brightness.light ||
            theme.brightness == Brightness.dark);
  }

  bool get _isLightGlass {
    return Theme.of(context).brightness ==
        Brightness.light;
  }

  Color get _glassBorder {
    return _isLightGlass
        ? Colors.white.withOpacity(0.62)
        : Colors.white.withOpacity(0.18);
  }

  Color get _glassFill {
    return _isLightGlass
        ? Colors.white.withOpacity(0.34)
        : Colors.white.withOpacity(0.065);
  }

  Color get _glassHighlight {
    return _isLightGlass
        ? Colors.white.withOpacity(0.72)
        : Colors.white.withOpacity(0.12);
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs =
        await SharedPreferences.getInstance();

    final notes =
        prefs.getStringList('notes') ?? [];

    if (!mounted) return;

    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveNotes() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      'notes',
      _notes,
    );
  }

  Future<void> _addNote() async {
    final title =
        _titleController.text.trim();

    final content =
        _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    final note = '$title\n$content';

    setState(() {
      _notes.insert(0, note);
    });

    _titleController.clear();
    _contentController.clear();

    await _saveNotes();
  }

  Future<void> _deleteNote(int index) async {
    if (index < 0 ||
        index >= _notes.length) {
      return;
    }

    setState(() {
      _notes.removeAt(index);
    });

    await _saveNotes();
  }

  Future<void> _showAddNoteDialog() async {
    _titleController.clear();
    _contentController.clear();

    await showDialog<void>(
      context: context,
     
