part of 'bookmark_cubit.dart';

class BookmarkState extends Equatable {
  final Set<String> bookmarkedIds;
  const BookmarkState({this.bookmarkedIds = const {}});

  bool isBookmarked(String opportunityId) => bookmarkedIds.contains(opportunityId);

  BookmarkState copyWith({Set<String>? bookmarkedIds}) {
    return BookmarkState(bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds);
  }

  @override
  List<Object?> get props => [bookmarkedIds];
}
