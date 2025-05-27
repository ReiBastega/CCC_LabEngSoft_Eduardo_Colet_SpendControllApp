enum ProfileStatus { initial, loading, failure, success }

class ProfileState {
  final ProfileStatus status;
  final String? errorMessage;

  const ProfileState({
    required this.status,
    this.errorMessage,
  });

  const ProfileState.initial()
      : this(
          status: ProfileStatus.initial,
          errorMessage: '',
        );

  List<Object?> get props => [
        status,
        errorMessage,
      ];

  ProfileState copyWith({
    ProfileStatus? status,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
