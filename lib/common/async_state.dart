/// State generik untuk pola "loading / data / error" pada pemuatan data
/// simulasi (lihat `TaskRepository.loadTasks`, `MemberRepository.loadMembers`).
enum LoadStatus { loading, data, error }

class AsyncListState<T> {
  final LoadStatus status;
  final List<T> items;
  final String? errorMessage;

  const AsyncListState.loading()
      : status = LoadStatus.loading,
        items = const [],
        errorMessage = null;

  const AsyncListState.data(this.items)
      : status = LoadStatus.data,
        errorMessage = null;

  const AsyncListState.error(this.errorMessage)
      : status = LoadStatus.error,
        items = const [];

  bool get isLoading => status == LoadStatus.loading;
  bool get isError => status == LoadStatus.error;
  bool get isData => status == LoadStatus.data;
}
