import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen

class NotesScreen extends StatefulWidget {
  final bool fromMore;
  const NotesScreen({super.key, this.fromMore = false});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load saved notes from SharedPreferences
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesString = prefs.getString('user_islamic_notes');
      if (notesString != null && notesString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(notesString);
        setState(() {
          _notes = List<Map<String, dynamic>>.from(decoded);
          _isLoading = false;
        });
      } else {
        setState(() {
          _notes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Save notes list to SharedPreferences
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_islamic_notes', jsonEncode(_notes));
  }

  // Add or Edit a Note
  void _openNoteDialog({Map<String, dynamic>? existingNote, int? index}) {
    final titleController =
    TextEditingController(text: existingNote?['title'] ?? '');
    final contentController =
    TextEditingController(text: existingNote?['content'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF101613),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existingNote == null ? 'Add New Note' : 'Edit Note',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: greyText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: whiteText, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Note Title (e.g. Daily Dua, Ayat)',
                    hintStyle: const TextStyle(color: greyText, fontSize: 13),
                    filled: true,
                    fillColor: card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: const TextStyle(color: whiteText, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Write your notes here...',
                    hintStyle: const TextStyle(color: greyText, fontSize: 13),
                    filled: true,
                    fillColor: card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final String title = titleController.text.trim();
                      final String content = contentController.text.trim();

                      if (title.isEmpty && content.isEmpty) return;

                      final String dateStr =
                      DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

                      setState(() {
                        if (index != null) {
                          _notes[index] = {
                            'title': title.isEmpty ? 'Untitled Note' : title,
                            'content': content,
                            'date': dateStr,
                          };
                        } else {
                          _notes.insert(0, {
                            'title': title.isEmpty ? 'Untitled Note' : title,
                            'content': content,
                            'date': dateStr,
                          });
                        }
                      });

                      _saveNotes();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_rounded, color: Colors.black),
                    label: Text(
                      existingNote == null ? 'Save Note' : 'Update Note',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete Note
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  void _handleBack() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => const MoreScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openNoteDialog(),
          backgroundColor: green,
          icon: const Icon(Icons.add_rounded, color: Colors.black),
          label: const Text(
            'New Note',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _headerSection(),
              Expanded(
                child: _isLoading
                    ? const Center(
                    child: CircularProgressIndicator(color: green))
                    : _notes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined,
                          color: gold.withValues(alpha: 0.5), size: 60),
                      const SizedBox(height: 14),
                      const Text(
                        'No Notes Saved Yet',
                        style: TextStyle(
                          color: whiteText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the button below to add your first note.',
                        style: TextStyle(color: greyText, fontSize: 12),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  cacheExtent: 2000,
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final String id = 'note_${note['title']}_${note['date']}';
                    return RepaintBoundary(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note['title'] ?? 'Untitled Note',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                FutureBuilder<bool>(
                                  future: FavoritesService.isFavorite(id),
                                  builder: (context, snapshot) {
                                    final isFav = snapshot.data ?? false;
                                    return IconButton(
                                      icon: Icon(
                                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isFav ? Colors.redAccent : greyText,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        await FavoritesService.toggleFavorite(
                                          id: id,
                                          category: 'Notes',
                                          title: note['title'] ?? 'Untitled Note',
                                          content: note['content'] ?? '',
                                          subtitle: note['date'] ?? '',
                                        );
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded,
                                      color: green, size: 22),
                                  onPressed: () => _openNoteDialog(
                                    existingNote: note,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 20),
                                  onPressed: () => _deleteNote(index),
                                ),
                              ],
                            ),
                            if ((note['content'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                note['content'],
                                style: const TextStyle(
                                  color: whiteText,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              note['date'] ?? '',
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: whiteText, size: 20),
          ),
          const SizedBox(width: 2),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.08),
              border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Icon(Icons.note_alt_rounded, color: gold, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONAL SAVES',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Islamic Notes',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}