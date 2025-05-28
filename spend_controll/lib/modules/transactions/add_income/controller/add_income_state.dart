import 'package:spend_controll/modules/transactions/model/group_model.dart';

class AddIncomeState {
  final bool isLoading;
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final List<Group> groups;

  const AddIncomeState({
    this.isLoading = false,
    this.isSaving = false,
    this.hasError = false,
    this.errorMessage,
    this.groups = const [],
  });

  factory AddIncomeState.initial() => const AddIncomeState();

  AddIncomeState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    List<Group>? groups,
  }) {
    return AddIncomeState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
    );
  }
}
