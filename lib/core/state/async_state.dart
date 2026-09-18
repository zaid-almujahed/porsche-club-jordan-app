enum AsyncStatus { initial, loading, success, failure }

class AsyncState<T> {
  const AsyncState._({
    required this.status,
    this.data,
    this.error,
    this.stackTrace,
  });

  const AsyncState.initial() : this._(status: AsyncStatus.initial);

  const AsyncState.loading({T? previousData})
    : this._(status: AsyncStatus.loading, data: previousData);

  const AsyncState.success(T data)
    : this._(status: AsyncStatus.success, data: data);

  const AsyncState.failure(
    Object error,
    StackTrace stackTrace, {
    T? previousData,
  }) : this._(
         status: AsyncStatus.failure,
         data: previousData,
         error: error,
         stackTrace: stackTrace,
       );

  final AsyncStatus status;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isInitial => status == AsyncStatus.initial;
  bool get isLoading => status == AsyncStatus.loading;
  bool get hasError => status == AsyncStatus.failure;
  bool get hasData => data != null;
}
