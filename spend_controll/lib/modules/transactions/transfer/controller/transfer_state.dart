import 'package:image_picker/image_picker.dart';
import 'package:spend_controll/modules/transactions/model/group_model.dart';

class TransferState {
  final bool isLoading;
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final List<Group> groups;
  final XFile? selectedImage;

  const TransferState({
    this.isLoading = false,
    this.isSaving = false,
    this.hasError = false,
    this.errorMessage,
    this.groups = const [],
    this.selectedImage,
  });

  factory TransferState.initial() => const TransferState();

  TransferState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    List<Group>? groups,
    XFile? selectedImage,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}
