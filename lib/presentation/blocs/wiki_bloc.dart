import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/wiki_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/note.dart';

// Events
abstract class WikiEvent extends Equatable {
  const WikiEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends WikiEvent {}

class AddCategory extends WikiEvent {
  final String name;
  final int? parentId;

  const AddCategory(this.name, {this.parentId});

  @override
  List<Object?> get props => [name, parentId];
}

class UpdateCategory extends WikiEvent {
  final CategoryEntity category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategory extends WikiEvent {
  final int categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class LoadNotes extends WikiEvent {
  final int categoryId;

  const LoadNotes(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class AddNote extends WikiEvent {
  final String title;
  final String content;
  final int categoryId;

  const AddNote(this.title, this.content, this.categoryId);

  @override
  List<Object> get props => [title, content, categoryId];
}

class UpdateNote extends WikiEvent {
  final NoteEntity note;

  const UpdateNote(this.note);

  @override
  List<Object> get props => [note];
}

class DeleteNote extends WikiEvent {
  final int noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object> get props => [noteId];
}

// States
abstract class WikiState extends Equatable {
  const WikiState();

  @override
  List<Object?> get props => [];
}

class WikiInitial extends WikiState {}

class CategoriesLoading extends WikiState {}

class CategoriesLoaded extends WikiState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class NotesLoading extends WikiState {}

class NotesLoaded extends WikiState {
  final List<NoteEntity> notes;
  final List<CategoryEntity> categories;

  const NotesLoaded(this.notes, this.categories);

  @override
  List<Object> get props => [notes, categories];
}

class WikiError extends WikiState {
  final String message;

  const WikiError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class WikiBloc extends Bloc<WikiEvent, WikiState> {
  final WikiRepository repository;

  WikiBloc(this.repository) : super(WikiInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<WikiState> emit) async {
    emit(CategoriesLoading());
    try {
      final categories = await repository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<WikiState> emit) async {
    try {
      await repository.createCategory(event.name, event.parentId);
      add(LoadCategories());
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<WikiState> emit) async {
    try {
      await repository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<WikiState> emit) async {
    try {
      await repository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<WikiState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await repository.getNotesForCategory(event.categoryId);
      final categories = await repository.getAllCategories();
      emit(NotesLoaded(notes, categories));
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<WikiState> emit) async {
    try {
      await repository.createNote(event.title, event.content, event.categoryId);
      add(LoadNotes(event.categoryId));
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<WikiState> emit) async {
    try {
      await repository.updateNote(event.note);
      add(LoadNotes(event.note.categoryId));
    } catch (e) {
      emit(WikiError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<WikiState> emit) async {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      final noteToDelete = currentState.notes.firstWhere((note) => note.id == event.noteId);
      try {
        await repository.deleteNote(event.noteId);
        add(LoadNotes(noteToDelete.categoryId));
      } catch (e) {
        emit(WikiError(e.toString()));
      }
    }
  }
}
