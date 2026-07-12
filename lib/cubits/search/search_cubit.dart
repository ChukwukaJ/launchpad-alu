import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';

part 'search_state.dart';

/// Deliberately separate from OpportunityCubit: search/filter state is UI
/// state (what the user is currently typing/toggling), while
/// OpportunityCubit owns the source-of-truth data stream from Firestore.
/// Splitting them means typing in the search box never re-subscribes to
/// Firestore, only re-filters what's already in memory.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setCategory(String? category) {
    emit(category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category));
  }

  void setWorkMode(WorkMode? mode) {
    emit(mode == null
        ? state.copyWith(clearWorkMode: true)
        : state.copyWith(workMode: mode));
  }

  void setPaidOnly(bool value) => emit(state.copyWith(paidOnly: value));

  void reset() => emit(const SearchState());
}
