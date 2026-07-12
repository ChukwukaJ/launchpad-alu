import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bookmark_repository.dart';

part 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _repository;
  final String uid;
  StreamSubscription<Set<String>>? _sub;

  BookmarkCubit({required this.uid, BookmarkRepository? repository})
      : _repository = repository ?? BookmarkRepository(),
        super(const BookmarkState()) {
    _sub = _repository.watchBookmarkedIds(uid).listen((ids) {
      emit(state.copyWith(bookmarkedIds: ids));
    });
  }

  Future<void> toggle(String opportunityId) async {
    final isSaved = state.isBookmarked(opportunityId);
    // Optimistic UI update — the Firestore stream will confirm/correct it
    // moments later, but the toggle feels instant to the user.
    final updated = Set<String>.from(state.bookmarkedIds);
    isSaved ? updated.remove(opportunityId) : updated.add(opportunityId);
    emit(state.copyWith(bookmarkedIds: updated));

    if (isSaved) {
      await _repository.removeBookmark(uid, opportunityId);
    } else {
      await _repository.addBookmark(uid, opportunityId);
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
