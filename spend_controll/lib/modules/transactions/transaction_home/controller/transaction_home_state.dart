enum TransactionHomeStatus { initial, loading, failure, success }

class TransactionHomeState {
  final TransactionHomeStatus status;
  const TransactionHomeState({
    required this.status,
  });

  const TransactionHomeState.initial()
      : this(
          status: TransactionHomeStatus.initial,
        );

  List<Object?> get props => [
        status,
      ];

  TransactionHomeState copyWith({
    TransactionHomeStatus? status,
  }) {
    return TransactionHomeState(
      status: status ?? this.status,
    );
  }
}
