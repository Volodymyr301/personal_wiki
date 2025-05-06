import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/database/database.dart';
import 'data/repositories/wiki_repository.dart';
import 'presentation/blocs/wiki_bloc.dart';
import 'presentation/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WikiRepository(AppDatabase()),
      child: BlocProvider(
        create: (context) => WikiBloc(
          context.read<WikiRepository>(),
        ),
        child: MaterialApp.router(
          title: 'Personal Wiki',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
