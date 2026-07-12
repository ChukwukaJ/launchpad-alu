part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String query;
  final String? category;
  final WorkMode? workMode;
  final bool paidOnly;

  const SearchState({
    this.query = '',
    this.category,
    this.workMode,
    this.paidOnly = false,
  });

  SearchState copyWith({
    String? query,
    String? category,
    bool clearCategory = false,
    WorkMode? workMode,
    bool clearWorkMode = false,
    bool? paidOnly,
  }) {
    return SearchState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      workMode: clearWorkMode ? null : (workMode ?? this.workMode),
      paidOnly: paidOnly ?? this.paidOnly,
    );
  }

  List<Opportunity> apply(List<Opportunity> source) {
    return source.where((o) {
      final matchesQuery = query.isEmpty ||
          o.title.toLowerCase().contains(query.toLowerCase()) ||
          o.startupName.toLowerCase().contains(query.toLowerCase()) ||
          o.requiredSkills.any((s) => s.toLowerCase().contains(query.toLowerCase()));
      final matchesPaid = !paidOnly || o.isPaid;
      return matchesQuery && matchesPaid;
    }).toList();
  }

  @override
  List<Object?> get props => [query, category, workMode, paidOnly];
}
