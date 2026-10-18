import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen
import 'settings_screen.dart';

class NotesScreen extends StatefulWidget {
  final bool fromMore;
  const NotesScreen({super.key, this.fromMore = false});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // ==========================================================
  // DYNAMIC PALETTE BASED ON DARK MODE STATE
  // ==========================================================
  bool get _isDark => ThemeService.isDarkMode.value;

  Color get appBackground => _isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1);
  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);

  static const Color primaryDeepEmerald = Color(0xFF164E3B);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  static const Color mutedGold = Color(0xFFB5964A);

  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get textInactive => _isDark ? const Color(0xFF718079) : const Color(0xFF718079);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

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
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: borderSubtle)),
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
                        color: richEmerald,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textInactive),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Note Title (e.g. Daily Dua, Ayat)',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: secondarySurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: richEmerald),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: TextStyle(color: textPrimary, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Write your notes here...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: secondarySurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: richEmerald),
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
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      existingNote == null ? 'Save Note' : 'Update Note',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: richEmerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (_, __, ___) => const MoreScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, darkEnabled, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBack();
          },
          child: Scaffold(
            backgroundColor: appBackground,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openNoteDialog(),
              backgroundColor: richEmerald,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'New Note',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _headerSection(),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                        child: CircularProgressIndicator(color: richEmerald))
                        : _notes.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_alt_outlined,
                              color: richEmerald.withValues(alpha: 0.4), size: 54),
                          const SizedBox(height: 14),
                          Text(
                            'No Notes Saved Yet',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the button below to add your first note.',
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),

                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        final String id = 'note_${note['title']}_${note['date']}';
                        return RepaintBoundary(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderSubtle),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                                          color: richEmerald,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    FutureBuilder<bool>(
                                      future: FavoritesService.isFavorite(id),
                                      builder: (context, snapshot) {
                                        final isFav = snapshot.data ?? false;
                                        return IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFav ? Colors.redAccent : textInactive,
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
                                    const SizedBox(width: 8),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.edit_note_rounded,
                                          color: richEmerald, size: 20),
                                      onPressed: () => _openNoteDialog(
                                        existingNote: note,
                                        index: index,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 18),
                                      onPressed: () => _deleteNote(index),
                                    ),
                                  ],
                                ),
                                if ((note['content'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    note['content'],
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Text(
                                  note['date'] ?? '',
                                  style: TextStyle(
                                    color: textInactive,
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
      },
    );
  }

  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: richEmerald,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: richEmerald),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondarySurface,
              border: Border.all(color: borderSubtle),
            ),
            child: const Icon(Icons.note_alt_rounded, color: richEmerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERSONAL SAVES',
                  style: TextStyle(
                    color: richEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Islamic Notes',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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