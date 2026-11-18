
class StateModel<T> {
  final T? data;
  final String? error;

  bool get isSuccess => error == null && data != null;

  StateModel._({this.data, this.error});

  factory StateModel.success(T data) => StateModel._(data: data);
  factory StateModel.error(String msg) => StateModel._(error: msg);
}

/// Null-safe helpers: work even when the provider result is `StateModel?`.
extension StateModelX on Object? {
  T? payload<T>() {
    final d = (this as dynamic)?.data;
    return d is T ? d : null;
  }

  String? errorText() => (this as dynamic)?.error?.toString();
}