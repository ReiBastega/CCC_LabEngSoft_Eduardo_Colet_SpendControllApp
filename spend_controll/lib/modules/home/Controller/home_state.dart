part of 'home_controller.dart';

enum HomeStatus { initial, loading, failure, success }

class HomeState {
  final HomeStatus status;
  final String? actualPassword;
  final String? token;

  const HomeState({
    required this.status,
    required this.actualPassword,
    required this.token,
  });

  const HomeState.initial()
      : this(
          status: HomeStatus.initial,
          actualPassword: '',
          token: '',
        );

  List<Object?> get props => [status, actualPassword, token];

  HomeState copyWith({
    HomeStatus? status,
    String? actualPassword,
    String? token,
  }) {
    return HomeState(
      status: status ?? this.status,
      actualPassword: actualPassword ?? this.actualPassword,
      token: token ?? this.token,
    );
  }
}
