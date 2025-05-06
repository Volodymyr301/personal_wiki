import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/wiki_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/category.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;

  const CategoryScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryEntity? _category;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadNotes() {
    context.read<WikiBloc>().add(LoadNotes(widget.categoryId));
  }



  void _showDeleteNoteDialog(BuildContext context, NoteEntity note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WikiBloc>().add(DeleteNote(note.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.read<WikiBloc>().add(LoadCategories());
            context.pop();
          },
        ).animate().fadeIn().scale(),
        title: Text(
          _category?.name ?? 'Category',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideX(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddCategoryDialog(context),
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
        child: BlocConsumer<WikiBloc, WikiState>(
          listener: (context, state) {
            if (state is NotesLoaded) {
              final category = state.categories.firstWhere(
                (category) => category.id == widget.categoryId,
                orElse: () => CategoryEntity(id: widget.categoryId, name: 'Category', createdAt: DateTime.now()),
              );
              setState(() {
                _category = category;
              });
            }
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return Center(
                  child: Text(
                    'No notes in this category',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: double.infinity,
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: GoogleFonts.spaceGroteskTextTheme(
                          Theme.of(context).textTheme,
                        ).apply(
                          bodyColor: Colors.white,
                          displayColor: Colors.white,
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: state.notes.length,
                        itemBuilder: (context, index) {
                          final note = state.notes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                note.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () => context.push('/category/${widget.categoryId}/note/${note.id}'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _showDeleteNoteDialog(context, note),
                                  ),
                                ],
                              ),
                              onTap: () => context.push('/category/${widget.categoryId}/note/${note.id}'),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX();
                        },
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                ),
              );
            }

            return Center(
              child: Text(
                'Something went wrong',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/category/${widget.categoryId}/note/new'),
        child: const Icon(Icons.note_add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subcategory'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                context.read<WikiBloc>().add(
                  AddCategory(textController.text, parentId: widget.categoryId),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
