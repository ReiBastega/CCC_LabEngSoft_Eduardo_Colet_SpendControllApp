part of 'home_controller.dart';

enum HomeStatus { initial, loading, failure, success }

class HomeState {
  final HomeStatus status;
  final String? errorMessege;

  const HomeState({
    required this.status,
    required this.errorMessege,
  });

  const HomeState.initial()
      : this(
          status: HomeStatus.initial,
          errorMessege: '',
        );

  List<Object?> get props => [status, errorMessege];

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessege,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessege: errorMessege ?? this.errorMessege,
    );
  }
}
