import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/note_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/note/new',
      builder: (context, state) => const NoteScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CategoryScreen(categoryId: id);
      },
      routes: [
        GoRoute(
          path: 'note/new',
          builder: (context, state) {
            final categoryId = int.parse(state.pathParameters['id']!);
            return NoteScreen(initialCategoryId: categoryId);
          },
        ),
        GoRoute(
          path: 'note/:noteId',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['noteId']!);
            return NoteScreen(noteId: id);
          },
        ),
      ],
    ),
  ],
);
