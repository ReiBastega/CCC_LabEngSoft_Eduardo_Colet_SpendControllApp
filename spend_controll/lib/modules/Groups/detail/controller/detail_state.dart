import 'package:spend_controll/modules/Groups/model/group_model.dart';

enum DetailStatus { initial, loading, failure, success }

enum DetailErrorType {
  initial,
  network,
  authentication,
  unknown,
}

class DetailState {
  final DetailStatus status;
  final DetailErrorType errorType;
  final Group? groups;
  final String? errorMessage;

  const DetailState({
    required this.errorType,
    required this.status,
    this.errorMessage,
    this.groups,
  });

  const DetailState.initial()
      : this(
          status: DetailStatus.initial,
          errorType: DetailErrorType.initial,
          errorMessage: '',
        );

  List<Object?> get props => [
        status,
        errorMessage,
        errorType,
        groups,
      ];

  DetailState copyWith({
    DetailStatus? status,
    String? errorMessage,
    Group? groups,
    DetailErrorType? errorType,
  }) {
    return DetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
      errorType: errorType ?? this.errorType,
    );
  }
}
