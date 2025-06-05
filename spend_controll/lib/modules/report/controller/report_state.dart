enum ReportStatus { initial, loading, failure, success }

class ReportState {
  final ReportStatus status;
  final String? errorMessage;

  const ReportState({
    required this.status,
    this.errorMessage,
  });

  const ReportState.initial()
      : this(
          status: ReportStatus.initial,
          errorMessage: '',
        );

  List<Object?> get props => [
        status,
        errorMessage,
      ];

  ReportState copyWith({
    ReportStatus? status,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
