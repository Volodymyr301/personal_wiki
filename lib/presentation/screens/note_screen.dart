import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_wiki/domain/entities/category.dart';
import '../blocs/wiki_bloc.dart';
import '../../domain/entities/note.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class NoteScreen extends StatefulWidget {
  final int? noteId;
  final int? initialCategoryId;

  const NoteScreen({
    super.key,
    this.noteId,
    this.initialCategoryId,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late int _selectedCategoryId;
  NoteEntity? _currentNote;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 0;
    
    if (widget.noteId != null) {
      _loadNote();
    }
    
    context.read<WikiBloc>().add(LoadCategories());
  }

  Future<void> _loadNote() async {
    try {
      final note = await context.read<WikiBloc>().repository.getNote(widget.noteId!);
      setState(() {
        _currentNote = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
        _selectedCategoryId = note.categoryId;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading note: $e')),
        );
      }
    }
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    if (_selectedCategoryId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_currentNote != null) {
      // Update existing note
      context.read<WikiBloc>().add(
        UpdateNote(
          _currentNote!.copyWith(
            title: _titleController.text,
            content: _contentController.text,
            categoryId: _selectedCategoryId,
          ),
        ),
      );
    } else {
      // Create new note
      context.read<WikiBloc>().add(
        AddNote(
          _titleController.text,
          _contentController.text,
          _selectedCategoryId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WikiBloc, WikiState>(
      listener: (context, state) {
        if (state is NotesLoaded) {
          if (widget.initialCategoryId != null) {
            // Якщо нотатка створюється/редагується з екрану категорії
            context.pop();
          } else {
            // Якщо нотатка створюється з головного екрану
            context.go('/');
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (widget.initialCategoryId != null) {
                context.pop();
                context.read<WikiBloc>().add(LoadNotes(widget.initialCategoryId!));
              } else {
                context.go('/');
              }
            },
          ).animate().fadeIn().scale(),
          title: Text(
            widget.noteId == null ? 'New Note' : 'Edit Note',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().slideX(),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveNote,
            ).animate().fadeIn().scale(),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.purple.shade900,
              ],
            ),
          ),
          child: BlocBuilder<WikiBloc, WikiState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              List<CategoryEntity> categories = [];
              if (state is CategoriesLoaded) {
                categories = state.categories;
              } else if (state is NotesLoaded) {
                categories = state.categories;
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 100,
                        borderRadius: 20,
                        blur: 20,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _titleController,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  labelStyle: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ).animate().fadeIn().slideX(),
                              const SizedBox(height: 20.0),
                              DropdownButtonFormField<int>(
                                value: _selectedCategoryId == 0 ? null : _selectedCategoryId,
                                dropdownColor: Colors.blue.shade900,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _buildCategoryDropdownItems(categories),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedCategoryId = value);
                                  }
                                },
                              ).animate().fadeIn().slideX(delay: 200.ms),
                              const SizedBox(height: 20.0),
                              Expanded(
                                child: TextField(
                                  controller: _contentController,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Content',
                                    alignLabelWithHint: true,
                                    labelStyle: GoogleFonts.spaceGrotesk(
                                      color: Colors.white70,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: null,
                                  expands: true,
                                ).animate().fadeIn().slideX(delay: 400.ms),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().scale(),
                    ],
                  ),
                ),
              );
          },
        ),
      ),
    ));
  }

  List<DropdownMenuItem<int>> _buildCategoryDropdownItems(List<CategoryEntity> categories, {String prefix = ''}) {
    return categories.expand((category) {
      final items = [
        DropdownMenuItem<int>(
          value: category.id,
          child: Text('$prefix${category.name}'),
        ),
      ];
      
      if (category.subcategories.isNotEmpty) {
        items.addAll(_buildCategoryDropdownItems(
          category.subcategories,
          prefix: '$prefix  ',
        ));
      }
      
      return items;
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
