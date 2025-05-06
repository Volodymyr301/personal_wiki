import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/wiki_bloc.dart';
import '../widgets/category_tree.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../domain/entities/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WikiBloc>().add(LoadCategories());
  }

  void _showAddCategoryDialog(BuildContext context, {CategoryEntity? parent}) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent == null ? 'Add Category' : 'Add Subcategory'),
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
                  AddCategory(textController.text, parentId: parent?.id),
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

  void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
    final textController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
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
                  UpdateCategory(
                    category.copyWith(name: textController.text),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WikiBloc>().add(DeleteCategory(category.id));
              Navigator.pop(context);
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
        title: Text(
          'Personal Wiki',
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
        child: BlocBuilder<WikiBloc, WikiState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            if (state is CategoriesLoaded) {
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
                    child: Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: GoogleFonts.spaceGroteskTextTheme(
                                Theme.of(context).textTheme,
                              ).apply(
                                bodyColor: Colors.white,
                                displayColor: Colors.white,
                              ),
                            ),
                            child: CategoryTree(
                              categories: state.categories,
                              onCategoryTap: (category) {
                                context.push('/category/${category.id}');
                              },
                              onCategoryEdit: (category) => _showEditCategoryDialog(context, category),
                              onCategoryDelete: (category) => _showDeleteCategoryDialog(context, category),
                            ),
                          ),
                        ).animate().fadeIn().slideX(),
                        Container(
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Select a category',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale(),
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
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
